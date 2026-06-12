defmodule TagIpWeb.ProfilMontageLive.Show do
  use TagIpWeb, :live_view

  alias TagIp.Resources.Compatibilite
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.ProfilMontage

  @impl true
  def mount(_params, _session, socket) do
    trackable_types = Ash.read!(TagIp.Resources.TrackableType)
    type_labels = Enum.into(trackable_types, %{}, fn t -> {t.slug, t.label} end)

    {:ok,
     socket
     |> assign(:type_labels, type_labels)
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)
     |> assign(:calculating, false)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    case Ash.get(TagIp.Resources.ProfilMontage, id) do
      {:ok, profil} ->
        profil =
          Ash.load!(profil, [
            :capteurs,
            :peripherals,
            :modele_traceur,
            :type_vehicule,
            :organisation,
            :alimentation
          ])

        compatibilites = list_compatibilites(id)

        {:noreply,
         socket
         |> assign(:page_title, "Profil: #{profil.name}")
         |> assign(:profil, profil)
         |> assign(:compatibilites, compatibilites)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Profil introuvable.")
         |> push_navigate(to: ~p"/profils")}
    end
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    case ProfilMontage.duplicate(id) do
      {:ok, profil} ->
        ProfilMontage.compute_compatibilities(profil.id)

        TagIp.Notification.broadcast(
          {:notification, :info, "Profil « #{profil.name} » dupliqué."}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Profil dupliqué avec succès.")}

      {:error, reason} ->
        {:noreply,
         put_flash(socket, :error, "Erreur lors de la duplication : #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event("calculate_compatibility", _params, socket) do
    profil = socket.assigns.profil

    _task =
      Task.async(fn ->
        modeles =
          Ash.read!(ModeleTraceur,
            page: [limit: 50],
            load: [:types_vehicule, :alimentations, :capteurs]
          )

        params = %{
          "object_type" => profil.object_type,
          "voltage_min" => profil.voltage_min,
          "voltage_max" => profil.voltage_max,
          "rs232_requis" => profil.rs232_requis,
          "rs485_requis" => profil.rs485_requis,
          "montage_exterieur" => profil.montage_exterieur,
          "ultra_low_power_requis" => profil.ultra_low_power_requis,
          "can_bus_requis" => profil.can_bus_requis,
          "one_wire_requis" => profil.one_wire_requis,
          "bluetooth_ble_requis" => profil.bluetooth_ble_requis,
          "inputs_requis" => profil.inputs_requis,
          "analog_inputs_requis" => profil.analog_inputs_requis,
          "outputs_requis" => profil.outputs_requis,
          "buzzer" => profil.buzzer,
          "geofence_enabled" => profil.geofence_enabled,
          "fuel_probe_type" => profil.fuel_probe_type,
          "antenne_deportee" => profil.antenne_deportee,
          "accelerometre_requis" => profil.accelerometre_requis
        }

        capteur_slugs = Enum.map(profil.capteurs || [], & &1.slug)
        peripheral_ids = Enum.map(profil.peripherals || [], & &1.id)

        compatibilities =
          modeles.results
          |> Enum.map(fn modele ->
            result =
              Compatibilite.calculer_depuis_params(params, modele, capteur_slugs, peripheral_ids)

            %{modele: modele, score: result.score, compatible: result.compatible}
          end)
          |> Enum.sort_by(fn c -> -c.score end)

        for compat <- compatibilities do
          Compatibilite
          |> Ash.ActionInput.for_action(:calculer_compatibilite, %{
            profil_id: profil.id,
            modele_id: compat.modele.id
          })
          |> Ash.run_action!()
        end

        %{profil_id: profil.id, count: length(compatibilities)}
      end)

    {:noreply, assign(socket, :calculating, true)}
  end

  @impl true
  def handle_event("confirm_delete", %{"id" => id}, socket) do
    case ProfilMontage |> Ash.get(id) do
      {:ok, profil} ->
        {:noreply,
         socket
         |> assign(:pending_delete_id, id)
         |> assign(:pending_delete_label, profil.name)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Profil introuvable.")}
    end
  end

  @impl true
  def handle_event("cancel_delete", _params, socket) do
    {:noreply,
     socket
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    id = socket.assigns.pending_delete_id

    case ProfilMontage |> Ash.get(id) do
      {:ok, profil} ->
        nom = profil.name

        case Ash.destroy(profil) do
          :ok ->
            TagIp.Notification.broadcast({:notification, :info, "Profil « #{nom} » supprimé."})

            {:noreply,
             socket
             |> put_flash(:info, "Profil « #{nom} » supprimé avec succès.")
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)
             |> push_navigate(to: ~p"/profils")}

          {:error, reason} ->
            {:noreply,
             socket
             |> put_flash(
               :error,
               "Erreur lors de la suppression du profil « #{nom} » : #{inspect(reason)}"
             )
             |> assign(:pending_delete_id, nil)
             |> assign(:pending_delete_label, nil)}
        end

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Profil introuvable.")
         |> assign(:pending_delete_id, nil)
         |> assign(:pending_delete_label, nil)}
    end
  end

  @impl true
  def handle_info({ref, result}, socket) do
    Process.demonitor(ref, [:flush])
    compatibilites = list_compatibilites(result.profil_id)

    {:noreply,
     socket
     |> assign(:compatibilites, compatibilites)
     |> assign(:calculating, false)
     |> put_flash(:info, "Compatibilité calculée pour #{result.count} modèles de traceurs.")}
  end

  def handle_info({:DOWN, _ref, :process, _pid, reason}, socket) do
    {:noreply,
     socket
     |> assign(:calculating, false)
     |> put_flash(:error, "Erreur lors du calcul : #{inspect(reason)}")}
  end

  defp list_compatibilites(profil_id) do
    Compatibilite
    |> Ash.Query.new()
    |> Ash.Query.limit(100)
    |> Ash.Query.do_filter(profil_montage_id: profil_id)
    |> Ash.Query.load([:modele_traceur])
    |> Ash.read!()
  end
end
