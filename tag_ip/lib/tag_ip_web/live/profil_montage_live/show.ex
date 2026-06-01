defmodule TagIpWeb.ProfilMontageLive.Show do
  use TagIpWeb, :live_view

  alias TagIp.Resources.Compatibilite
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.ProfilMontage
  alias TagIp.Resources.ProfilMontageCapteur

  @impl true
  def mount(_params, _session, socket) do
    trackable_types = Ash.read!(TagIp.Resources.TrackableType)
    type_labels = Enum.into(trackable_types, %{}, fn t -> {t.slug, t.label} end)

    {:ok,
     socket
     |> assign(:type_labels, type_labels)
     |> assign(:pending_delete_id, nil)
     |> assign(:pending_delete_label, nil)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    profil = Ash.get!(TagIp.Resources.ProfilMontage, id) |> Ash.load!(:capteurs)
    compatibilites = list_compatibilites(id)

    {:noreply,
     socket
     |> assign(:page_title, "Profil: #{profil.name}")
     |> assign(:profil, profil)
     |> assign(:compatibilites, compatibilites)}
  end

  defp list_compatibilites(profil_id) do
    Compatibilite
    |> Ash.Query.new()
    |> Ash.Query.limit(100)
    |> Ash.Query.do_filter(profil_montage_id: profil_id)
    |> Ash.Query.load([:modele_traceur])
    |> Ash.read!()
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    case ProfilMontage |> Ash.get(id) do
      {:ok, source} ->
        source = Ash.load!(source, [:capteurs])

        attrs = %{
          name: source.name,
          description: source.description,
          reporting_interval: source.reporting_interval,
          object_type: source.object_type,
          voltage_min: source.voltage_min,
          voltage_max: source.voltage_max,
          buzzer: source.buzzer,
          fuel_probe_type: source.fuel_probe_type,
          geofence_enabled: source.geofence_enabled,
          driver_id_type: source.driver_id_type,
          can_bus_requis: source.can_bus_requis,
          one_wire_requis: source.one_wire_requis,
          rs232_requis: source.rs232_requis,
          rs485_requis: source.rs485_requis,
          inputs_requis: source.inputs_requis,
          analog_inputs_requis: source.analog_inputs_requis,
          outputs_requis: source.outputs_requis,
          montage_exterieur: source.montage_exterieur,
          antenne_deportee: source.antenne_deportee,
          accelerometre_requis: source.accelerometre_requis,
          ultra_low_power_requis: source.ultra_low_power_requis
        }

        source_capteur_ids = Enum.map(source.capteurs || [], & &1.id)

        case ProfilMontage.create(attrs) do
          {:ok, profil} ->
            sync_capteurs(profil.id, source_capteur_ids)

            modeles =
              Ash.read!(ModeleTraceur,
                page: [limit: 50],
                load: [:types_vehicule, :alimentations, :capteurs]
              )

            params =
              attrs
              |> Enum.map(fn {k, v} -> {to_string(k), v} end)
              |> Map.new()

            compatibilities =
              modeles.results
              |> Enum.map(fn modele ->
                result = Compatibilite.calculer_depuis_params(params, modele)
                %{modele: modele, compatible: result.compatible, score: result.score}
              end)
              |> Enum.sort_by(fn c -> -c.score end)

            for compat <- compatibilities, compat.compatible do
              Compatibilite
              |> Ash.ActionInput.for_action(:calculer_compatibilite, %{
                profil_id: profil.id,
                modele_id: compat.modele.id
              })
              |> Ash.run_action!()
            end

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

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Profil introuvable.")}
    end
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

  defp sync_capteurs(profil_id, selected_ids) do
    existing =
      ProfilMontageCapteur.read!()
      |> Enum.filter(&(&1.profil_montage_id == profil_id))

    Enum.each(existing, &ProfilMontageCapteur.destroy(&1))

    Enum.each(selected_ids, fn id ->
      ProfilMontageCapteur.create(%{
        profil_montage_id: profil_id,
        capteur_id: id
      })
    end)
  end
end
