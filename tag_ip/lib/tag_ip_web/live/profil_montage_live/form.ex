defmodule TagIpWeb.ProfilMontageLive.Form do
  use TagIpWeb, :live_view

  alias AshPhoenix.Form
  alias TagIp.Resources.ProfilMontage
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.Compatibilite
  alias TagIp.Resources.TrackableType

  @steps [
    %{num: 1, title: "Identification", description: "Nom et description du profil"},
    %{num: 2, title: "Configuration", description: "Asset, interfaces et entrées/sorties"},
    %{num: 3, title: "Tension", description: "Seuils électriques"},
    %{num: 4, title: "Équipements", description: "Capteurs et options"},
    %{num: 5, title: "Compatibilités", description: "Modèles de traceurs compatibles"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    trackable_types = TrackableType.read!()

    object_type_options =
      Enum.map(trackable_types, fn tt ->
        {tt.label, tt.slug}
      end)

    modeles =
      Ash.read!(ModeleTraceur,
        page: [limit: 50],
        load: [:types_vehicule, :alimentations, :capteurs]
      )

    {:ok,
     socket
     |> assign(:step, 1)
     |> assign(:total_steps, length(@steps))
     |> assign(:steps, @steps)
     |> assign(:object_type_options, object_type_options)
     |> assign(:modeles, modeles.results)
     |> assign(:compatibilities, [])}
  end

  @impl true
  def handle_params(params, url, socket) do
    path = URI.parse(url).path

    {:noreply,
     socket
     |> assign(:current_path, path)
     |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("next-step", _params, socket) do
    step = socket.assigns.step
    total = socket.assigns.total_steps

    if step < total do
      {:noreply, assign(socket, :step, step + 1)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("prev-step", _params, socket) do
    step = socket.assigns.step

    if step > 1 do
      {:noreply, assign(socket, :step, step - 1)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"profil_montage" => params}, socket) do
    form =
      socket.assigns.form.source
      |> Form.validate(params)
      |> to_form()

    compatibilities = compute_compatibilities(params, socket.assigns.modeles)

    {:noreply, assign(socket, :form, form) |> assign(:compatibilities, compatibilities)}
  end

  @impl true
  def handle_event("save", %{"profil_montage" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, profil} ->
        for compat <- socket.assigns.compatibilities, compat.compatible do
          Compatibilite
          |> Ash.ActionInput.for_action(:calculer_compatibilite, %{
            profil_id: profil.id,
            modele_id: compat.modele.id
          })
          |> Ash.run_action!()
        end

        compat_count = Enum.count(socket.assigns.compatibilities, & &1.compatible)

        message =
          if socket.assigns.profil do
            "Profil de montage modifié avec succès !"
          else
            "Profil de montage créé avec succès ! #{compat_count} compatibilité(s) enregistrée(s)."
          end

        TagIp.Notification.broadcast({:notification, :info, message})

        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/profils")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  defp apply_action(socket, :new, %{"duplicate_from" => source_id}) do
    source = Ash.get!(ProfilMontage, source_id, domain: TagIp.TagIp)

    params = source_params(source, "#{source.name} (copie)")
    compatibilities = compute_compatibilities(params, socket.assigns.modeles)

    form =
      Form.for_create(ProfilMontage, :create, as: "profil_montage", domain: TagIp.TagIp)
      |> Form.validate(params)
      |> to_form()

    socket
    |> assign(:page_title, "Dupliquer le profil #{source.name}")
    |> assign(:form, form)
    |> assign(:profil, nil)
    |> assign(:compatibilities, compatibilities)
  end

  defp apply_action(socket, :new, _params) do
    form =
      Form.for_create(ProfilMontage, :create, as: "profil_montage", domain: TagIp.TagIp)
      |> to_form()

    socket
    |> assign(:page_title, "Nouveau profil de montage")
    |> assign(:form, form)
    |> assign(:profil, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    profil = Ash.get!(ProfilMontage, id, domain: TagIp.TagIp)

    form =
      Form.for_update(profil, :update, as: "profil_montage")
      |> to_form()

    params = %{
      "object_type" => profil.object_type,
      "voltage_min" => profil.voltage_min,
      "voltage_max" => profil.voltage_max,
      "buzzer" => profil.buzzer,
      "fuel_probe_type" => profil.fuel_probe_type,
      "geofence_enabled" => profil.geofence_enabled,
      "can_bus_requis" => profil.can_bus_requis,
      "one_wire_requis" => profil.one_wire_requis,
      "rs232_requis" => profil.rs232_requis,
      "rs485_requis" => profil.rs485_requis,
      "inputs_requis" => profil.inputs_requis,
      "analog_inputs_requis" => profil.analog_inputs_requis,
      "outputs_requis" => profil.outputs_requis,
      "ip_rating" => profil.ip_rating,
      "montage_exterieur" => profil.montage_exterieur,
      "antenne_deportee" => profil.antenne_deportee,
      "accelerometre_requis" => profil.accelerometre_requis,
      "buffer_requis" => profil.buffer_requis,
      "ultra_low_power_requis" => profil.ultra_low_power_requis
    }

    compatibilities = compute_compatibilities(params, socket.assigns.modeles)

    socket
    |> assign(:page_title, "Modifier le profil #{profil.name}")
    |> assign(:form, form)
    |> assign(:profil, profil)
    |> assign(:compatibilities, compatibilities)
  end

  defp source_params(profil, name) do
    %{
      "name" => name,
      "description" => profil.description,
      "reporting_interval" => profil.reporting_interval,
      "driver_id_type" => profil.driver_id_type,
      "object_type" => profil.object_type,
      "voltage_min" => profil.voltage_min,
      "voltage_max" => profil.voltage_max,
      "buzzer" => profil.buzzer,
      "fuel_probe_type" => profil.fuel_probe_type,
      "geofence_enabled" => profil.geofence_enabled,
      "can_bus_requis" => profil.can_bus_requis,
      "one_wire_requis" => profil.one_wire_requis,
      "rs232_requis" => profil.rs232_requis,
      "rs485_requis" => profil.rs485_requis,
      "inputs_requis" => profil.inputs_requis,
      "analog_inputs_requis" => profil.analog_inputs_requis,
      "outputs_requis" => profil.outputs_requis,
      "ip_rating" => profil.ip_rating,
      "montage_exterieur" => profil.montage_exterieur,
      "antenne_deportee" => profil.antenne_deportee,
      "accelerometre_requis" => profil.accelerometre_requis,
      "buffer_requis" => profil.buffer_requis,
      "ultra_low_power_requis" => profil.ultra_low_power_requis
    }
  end

  defp compute_compatibilities(params, modeles) do
    modeles
    |> Enum.map(fn modele ->
      result = Compatibilite.calculer_depuis_params(params, modele)

      %{
        modele: modele,
        score: result.score,
        compatible: result.compatible,
        details: result.details
      }
    end)
    |> Enum.sort_by(fn c -> -c.score end)
  end
end
