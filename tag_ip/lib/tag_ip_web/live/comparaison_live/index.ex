defmodule TagIpWeb.ComparaisonLive.Index do
  use TagIpWeb, :live_view

  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.Peripheral
  alias TagIp.Resources.CapabilityMatrix
  alias TagIp.Resources.ProfileComparaison
  alias TagIp.Resources.Alimentation
  alias TagIp.Resources.Capteur
  alias TagIp.Resources.TypeVehicule

  @steps [
    %{
      num: 1,
      title: "Étape 1 : Type de traceur",
      description: "Étape 1 : Marque et type de véhicule"
    },
    %{
      num: 2,
      title: "Étape 2 : Fonctionnalités",
      description: "Étape 2 : Besoins fonctionnels du client"
    },
    %{
      num: 3,
      title: "Étape 3 : Équipements",
      description: "Étape 3 : Alimentation, capteurs et périphériques"
    },
    %{
      num: 4,
      title: "Étape 4 : Résultats",
      description: "Étape 4 : Comparaison et validation"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    modeles = ModeleTraceur.read!()

    modeles =
      Enum.map(modeles, fn m ->
        Ash.load!(m, [:features, :capteurs, :alimentations, :types_vehicule, :model_ports])
      end)

    features = CapabilityMatrix.matrix_features()
    peripherals = Peripheral.read!() |> Enum.sort_by(& &1.name)
    alimentations = Alimentation.read!() |> Enum.sort_by(& &1.label)
    capteurs = Capteur.read!() |> Enum.sort_by(& &1.label)
    types_vehicule = TypeVehicule.read!() |> Enum.sort_by(& &1.label)
    brands = modeles |> Enum.map(& &1.brand) |> Enum.uniq() |> Enum.sort()

    {:ok,
     socket
     |> assign(:page_title, "Comparaison technique des traceurs GPS")
     |> assign(:step, 1)
     |> assign(:total_steps, length(@steps))
     |> assign(:steps, @steps)
     |> assign(:modeles, modeles)
     |> assign(:features, features)
     |> assign(:peripherals, peripherals)
     |> assign(:alimentations, alimentations)
     |> assign(:capteurs, capteurs)
     |> assign(:types_vehicule, types_vehicule)
     |> assign(:brands, brands)
     |> assign(:selected_brands, MapSet.new())
     |> assign(:selected_feature_slugs, MapSet.new())
     |> assign(:selected_peripheral_ids, MapSet.new())
     |> assign(:selected_alimentation_ids, MapSet.new())
     |> assign(:selected_capteur_ids, MapSet.new())
     |> assign(:selected_type_vehicule_ids, MapSet.new())
     |> assign(:selected_model_ids, MapSet.new())
     |> assign(:show_cards, false)
     |> assign(:sort_desc, true)
     |> assign(:compatible_modeles, modeles)
     |> assign(:total_count, length(modeles))
     |> assign(:saved, false)}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Comparaison technique des traceurs GPS")
     |> assign(:current_path, URI.parse(url).path)}
  end

  @impl true
  def handle_event("toggle_brand", %{"brand" => brand}, socket) do
    {:noreply,
     assign(socket, :selected_brands, toggle_set(socket.assigns.selected_brands, brand))}
  end

  @impl true
  def handle_event("toggle_feature", %{"slug" => slug}, socket) do
    {:noreply,
     assign(
       socket,
       :selected_feature_slugs,
       toggle_set(socket.assigns.selected_feature_slugs, slug)
     )}
  end

  @impl true
  def handle_event("brand_changed", %{"brand" => brand}, socket) do
    selected = if brand in [nil, ""], do: MapSet.new(), else: MapSet.new([brand])
    {:noreply, assign(socket, :selected_brands, selected) |> filter()}
  end

  @impl true
  def handle_event("type_changed", %{"type" => type}, socket) do
    selected =
      case type do
        nil -> MapSet.new()
        "" -> MapSet.new()
        v -> MapSet.new([parse_id(v)])
      end

    {:noreply, assign(socket, :selected_type_vehicule_ids, selected) |> filter()}
  end

  @impl true
  def handle_event("alimentation_changed", %{"alimentation" => val}, socket) do
    selected =
      case val do
        nil -> MapSet.new()
        "" -> MapSet.new()
        v -> MapSet.new([parse_id(v)])
      end

    {:noreply, assign(socket, :selected_alimentation_ids, selected) |> filter()}
  end

  @impl true
  def handle_event("capteur_changed", %{"capteur" => val}, socket) do
    selected =
      case val do
        nil -> MapSet.new()
        "" -> MapSet.new()
        v -> MapSet.new([parse_id(v)])
      end

    {:noreply, assign(socket, :selected_capteur_ids, selected) |> filter()}
  end

  @impl true
  def handle_event("peripheral_changed", %{"peripheral" => val}, socket) do
    selected =
      case val do
        nil -> MapSet.new()
        "" -> MapSet.new()
        v -> MapSet.new([parse_id(v)])
      end

    {:noreply, assign(socket, :selected_peripheral_ids, selected) |> filter()}
  end

  @impl true
  def handle_event("toggle_peripheral", %{"id" => id}, socket) do
    {:noreply,
     assign(
       socket,
       :selected_peripheral_ids,
       toggle_set(socket.assigns.selected_peripheral_ids, id)
     )}
  end

  @impl true
  def handle_event("toggle_alimentation", %{"id" => id}, socket) do
    {:noreply,
     assign(
       socket,
       :selected_alimentation_ids,
       toggle_set(socket.assigns.selected_alimentation_ids, id)
     )}
  end

  @impl true
  def handle_event("toggle_capteur", %{"id" => id}, socket) do
    {:noreply,
     assign(socket, :selected_capteur_ids, toggle_set(socket.assigns.selected_capteur_ids, id))}
  end

  @impl true
  def handle_event("toggle_type_vehicule", %{"id" => id}, socket) do
    {:noreply,
     assign(
       socket,
       :selected_type_vehicule_ids,
       toggle_set(socket.assigns.selected_type_vehicule_ids, id)
     )}
  end

  @impl true
  def handle_event("next_step", _params, socket) do
    case socket.assigns.step do
      1 -> {:noreply, assign(socket, :step, 2)}
      2 -> {:noreply, assign(socket, :step, 3)}
      3 -> {:noreply, assign(socket, :step, 4) |> filter()}
      4 -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("prev_step", _params, socket) do
    {:noreply, assign(socket, :step, socket.assigns.step - 1)}
  end

  @impl true
  def handle_event("go_to_step", %{"step" => step}, socket) do
    {:noreply, assign(socket, :step, String.to_integer(step))}
  end

  @impl true
  def handle_event("save", _params, socket) do
    user_id = socket.assigns.current_scope.user.id
    compatible_tracker_ids = Enum.map(socket.assigns.compatible_modeles, & &1.id)

    case ProfileComparaison.create(%{
           feature_slugs: MapSet.to_list(socket.assigns.selected_feature_slugs),
           peripheral_ids: MapSet.to_list(socket.assigns.selected_peripheral_ids),
           compatible_tracker_ids: compatible_tracker_ids,
           user_id: user_id
         }) do
      {:ok, _profile} ->
        {:noreply,
         socket
         |> assign(:saved, true)
         |> put_flash(:info, "Comparaison enregistrée avec succès !")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Erreur lors de l'enregistrement : #{inspect(changeset.errors)}")}
    end
  end

  @impl true
  def handle_event("toggle_sort", _params, socket) do
    socket = assign(socket, :sort_desc, !socket.assigns.sort_desc)
    {:noreply, filter(socket)}
  end

  @impl true
  def handle_event("toggle_select_model", %{"id" => id_raw}, socket) do
    id = parse_id(id_raw)

    selected = socket.assigns.selected_model_ids

    new_set =
      if MapSet.member?(selected, id),
        do: MapSet.delete(selected, id),
        else: MapSet.put(selected, id)

    {:noreply, assign(socket, :selected_model_ids, new_set)}
  end

  @impl true
  def handle_event("compare_selected", _params, socket) do
    {:noreply, assign(socket, :show_cards, true)}
  end

  @impl true
  def handle_event("clear_selection", _params, socket) do
    {:noreply, assign(socket, :selected_model_ids, MapSet.new()) |> assign(:show_cards, false)}
  end

  defp parse_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> int
      :error -> id
    end
  end

  defp parse_id(id), do: id

  defp toggle_set(set, value) do
    if MapSet.member?(set, value) do
      MapSet.delete(set, value)
    else
      MapSet.put(set, value)
    end
  end

  defp filter(socket) do
    modeles = socket.assigns.modeles

    # helper to compute score per modele based on selected criteria
    selected = %{
      brands: socket.assigns.selected_brands,
      features: socket.assigns.selected_feature_slugs,
      peripherals: socket.assigns.selected_peripheral_ids,
      alimentations: socket.assigns.selected_alimentation_ids,
      capteurs: socket.assigns.selected_capteur_ids,
      types: socket.assigns.selected_type_vehicule_ids
    }

    {scores_map, scored} =
      modeles
      |> Enum.map(fn m -> {m, compute_score(m, selected, socket.assigns.peripherals)} end)
      |> Enum.reduce({%{}, []}, fn {m, score}, {scores, acc} ->
        {Map.put(scores, m.id, score), [{m, score} | acc]}
      end)

    # If user selected no criteria, show all models; otherwise show models with score > 0
    any_selected =
      Enum.any?(
        [
          MapSet.size(selected.brands),
          MapSet.size(selected.features),
          MapSet.size(selected.peripherals),
          MapSet.size(selected.alimentations),
          MapSet.size(selected.capteurs),
          MapSet.size(selected.types)
        ],
        &(&1 > 0)
      )

    filtered =
      scored
      |> Enum.filter(fn {_m, score} -> not any_selected or score > 0 end)
      |> Enum.sort_by(
        fn {_m, score} -> score end,
        if(socket.assigns.sort_desc, do: :desc, else: :asc)
      )
      |> Enum.map(fn {m, _s} -> m end)

    assign(socket, :compatible_modeles, filtered)
    |> assign(:total_count, length(filtered))
    |> assign(:scores, scores_map)
  end

  def compute_score(modele, selected, peripherals) do
    # Each of the 6 categories contributes equally (1/6 of total score).
    # Within a category: matched / selected = ratio for that category.
    # This prevents 100% from selecting only 1 category.

    features_ratio =
      if MapSet.size(selected.features) == 0 do
        0
      else
        matched =
          (modele.features &&
             Enum.count(modele.features, &MapSet.member?(selected.features, &1.slug))) || 0

        matched / MapSet.size(selected.features)
      end

    peripherals_ratio =
      if MapSet.size(selected.peripherals) == 0 do
        0
      else
        matched =
          Enum.count(MapSet.to_list(selected.peripherals), fn pid ->
            p = Enum.find(peripherals, &(&1.id == pid))

            if p do
              model_ports = modele.model_ports || []
              port_type_ids = Enum.map(model_ports, & &1.port_type_id) |> MapSet.new()
              MapSet.member?(port_type_ids, p.port_type_id)
            else
              false
            end
          end)

        matched / MapSet.size(selected.peripherals)
      end

    alimentations_ratio =
      if MapSet.size(selected.alimentations) == 0 do
        0
      else
        matched =
          (modele.alimentations &&
             Enum.count(modele.alimentations, &MapSet.member?(selected.alimentations, &1.id))) ||
            0

        matched / MapSet.size(selected.alimentations)
      end

    capteurs_ratio =
      if MapSet.size(selected.capteurs) == 0 do
        0
      else
        matched =
          (modele.capteurs &&
             Enum.count(modele.capteurs, &MapSet.member?(selected.capteurs, &1.id))) || 0

        matched / MapSet.size(selected.capteurs)
      end

    types_ratio =
      if MapSet.size(selected.types) == 0 do
        0
      else
        matched =
          (modele.types_vehicule &&
             Enum.count(modele.types_vehicule, &MapSet.member?(selected.types, &1.id))) || 0

        matched / MapSet.size(selected.types)
      end

    brands_ratio =
      if MapSet.size(selected.brands) == 0 do
        0
      else
        if MapSet.member?(selected.brands, modele.brand), do: 1, else: 0
      end

    total_categories = 6

    weighted =
      features_ratio + peripherals_ratio + alimentations_ratio + capteurs_ratio + types_ratio +
        brands_ratio

    round(weighted / total_categories * 100)
  end

  # NOTE: several granular "passes_*" helpers were removed because the
  # filtering and scoring logic is centralized in `compute_score/3` and
  # `filter/1`. Keeping them would produce unused-function warnings.

  def feature_supported?(modele, slug) do
    modele.features && Enum.any?(modele.features, &(&1.slug == slug))
  end

  def supplier_label(supplier) do
    case supplier do
      "Wondeproud" -> "WonderProud"
      other -> other
    end
  end

  def feature_label(slug) do
    case slug do
      "alert_button" -> "Alerte bouton (SOS)"
      "buzzer_feature" -> "Buzzer"
      "driver_id" -> "ID chauffeur"
      "green_driving" -> "Green Driving"
      "fuel_cap" -> "Bouchon réservoir"
      "fuel_analog" -> "Carburant (Analogique)"
      "fuel_rs232" -> "Carburant (RS232)"
      "fuel_ble" -> "Carburant (BLE)"
      "fuel_can" -> "Carburant (CAN)"
      "crash_detection" -> "Crash Detection"
      _ -> slug
    end
  end
end
