defmodule TagIpWeb.CompatibiliteLive.Assistant do
  use TagIpWeb, :live_view

  alias TagIp.Resources.Compatibilite
  alias TagIp.Resources.ModeleTraceur
  alias TagIp.Resources.TypeVehicule
  alias TagIp.Resources.Capteur
  alias TagIp.Resources.Peripheral

  @impl true
  def mount(params, _session, socket) do
    types_vehicule = Ash.read!(TypeVehicule)
    capteurs = Ash.read!(Capteur)
    peripherals = Ash.read!(Peripheral)

    {:ok,
     socket
     |> assign(:step, parse_step(params))
     |> assign(:types_vehicule, types_vehicule)
     |> assign(:capteurs, capteurs)
     |> assign(:peripherals, peripherals)
     |> assign(:results, [])
     |> assign(:profil_params, default_params())
     |> assign(:page_title, "Assistant Compatibilité")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    step = parse_step(params)
    {:noreply, assign(socket, :step, step)}
  end

  # ---------------------------------------------------------------------------
  # Step 1 -> Step 2
  # ---------------------------------------------------------------------------
  @impl true
  def handle_event("next_step_1", %{"step1" => params}, socket) do
    profil_params = merge_params(socket.assigns.profil_params, params)

    {:noreply,
     socket
     |> assign(:profil_params, profil_params)
     |> push_patch(to: ~p"/compatibilites/assistant?step=2")}
  end

  # ---------------------------------------------------------------------------
  # Step 2 -> Step 3
  # ---------------------------------------------------------------------------
  def handle_event("next_step_2", %{"step2" => params}, socket) do
    profil_params = merge_params(socket.assigns.profil_params, params)

    {:noreply,
     socket
     |> assign(:profil_params, profil_params)
     |> push_patch(to: ~p"/compatibilites/assistant?step=3")}
  end

  # ---------------------------------------------------------------------------
  # Step 3 -> Step 4 (calculate)
  # ---------------------------------------------------------------------------
  def handle_event("next_step_3", %{"step3" => params}, socket) do
    profil_params = merge_params(socket.assigns.profil_params, params)

    capteur_slugs =
      params
      |> Map.get("capteur_slugs", [])
      |> List.wrap()

    peripheral_ids =
      params
      |> Map.get("peripheral_ids", [])
      |> List.wrap()

    results = calculate_all(profil_params, capteur_slugs, peripheral_ids)

    {:noreply,
     socket
     |> assign(:profil_params, profil_params)
     |> assign(:results, results)
     |> push_patch(to: ~p"/compatibilites/assistant?step=4")}
  end

  # ---------------------------------------------------------------------------
  # Navigation back
  # ---------------------------------------------------------------------------
  def handle_event("prev_step", _params, socket) do
    step = max(1, socket.assigns.step - 1)
    {:noreply, push_patch(socket, to: ~p"/compatibilites/assistant?step=#{step}")}
  end

  def handle_event("restart", _params, socket) do
    {:noreply,
     socket
     |> assign(:results, [])
     |> assign(:profil_params, default_params())
     |> push_patch(to: ~p"/compatibilites/assistant?step=1")}
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------
  defp default_params do
    %{
      "object_type" => "",
      "voltage_min" => "",
      "voltage_max" => "",
      "montage_exterieur" => "false",
      "antenne_deportee" => "false",
      "can_bus_requis" => "false",
      "one_wire_requis" => "false",
      "rs232_requis" => "false",
      "rs485_requis" => "false",
      "bluetooth_ble_requis" => "false",
      "inputs_requis" => "0",
      "analog_inputs_requis" => "0",
      "outputs_requis" => "0",
      "accelerometre_requis" => "false",
      "ultra_low_power_requis" => "false",
      "buzzer" => "false",
      "geofence_enabled" => "false",
      "fuel_probe_type" => ""
    }
  end

  defp merge_params(existing, new) do
    new = Map.drop(new, ["_target"])

    new =
      Map.new(new, fn {k, v} ->
        {k, if(is_list(v), do: v, else: to_string(v))}
      end)

    Map.merge(existing, new)
  end

  defp calculate_all(profil_params, capteur_slugs, peripheral_ids) do
    modeles =
      ModeleTraceur
      |> Ash.read!(load: [:types_vehicule, :alimentations, :capteurs, :model_ports])

    modeles.results
    |> Enum.map(fn modele ->
      result =
        Compatibilite.calculer_depuis_params(profil_params, modele, capteur_slugs, peripheral_ids)

      %{
        modele: modele,
        score: result.score,
        compatible: result.compatible,
        details: result.details
      }
    end)
    |> Enum.sort_by(& &1.score, :desc)
  end

  defp score_color(score) do
    cond do
      score >= 70 -> "bg-green-100 text-green-800 border-green-200"
      score >= 40 -> "bg-yellow-100 text-yellow-800 border-yellow-200"
      true -> "bg-red-100 text-red-800 border-red-200"
    end
  end

  defp score_bar_width(score) do
    "width: #{score}%"
  end

  defp count_compatible(results) do
    Enum.count(results, & &1.compatible)
  end

  defp parse_step(params) do
    case Map.get(params, "step") do
      nil ->
        1

      step_str ->
        case Integer.parse(step_str) do
          {n, _} when n >= 1 and n <= 4 -> n
          _ -> 1
        end
    end
  end

  # ---------------------------------------------------------------------------
  # Component helpers
  # ---------------------------------------------------------------------------
  attr :step, :integer, required: true
  attr :current, :integer, required: true
  attr :label, :string, required: true

  defp step_indicator(assigns) do
    active = assigns.current == assigns.step
    done = assigns.current > assigns.step

    assigns =
      assign(assigns, :active, active)

    assign(assigns, :done, done)

    ~H"""
    <div class="flex items-center gap-2">
      <div class={[
        "w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold border-2 transition-all",
        @active && "bg-blue-600 text-white border-blue-600 shadow-lg",
        @done && "bg-green-500 text-white border-green-500",
        !@active && !@done && "bg-white text-gray-400 border-gray-300"
      ]}>
        <%= if @done do %>
          <.icon name="hero-check" class="size-4" />
        <% else %>
          {@step}
        <% end %>
      </div>
      <span class={[
        "text-sm font-medium hidden sm:inline",
        @active && "text-blue-600",
        @done && "text-green-600",
        !@active && !@done && "text-gray-400"
      ]}>
        {@label}
      </span>
    </div>
    """
  end

  defp step_arrow(assigns) do
    ~H"""
    <div class="w-8 h-px bg-gray-300 hidden sm:block"></div>
    """
  end

  attr :name, :string, required: true
  attr :label, :string, required: true
  attr :checked, :boolean, default: false

  defp toggle_field(assigns) do
    ~H"""
    <label class={[
      "flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all",
      @checked && "bg-blue-50 border-blue-300",
      !@checked && "bg-white border-gray-200 hover:border-gray-300"
    ]}>
      <input
        type="hidden"
        name={@name}
        value="false"
      />
      <input
        type="checkbox"
        name={@name}
        value="true"
        checked={@checked}
        class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
      />
      <span class="text-sm font-medium text-gray-700">{@label}</span>
    </label>
    """
  end

  slot :inner_block, required: true

  defp criteria_badge(assigns) do
    ~H"""
    <span class="inline-flex items-center px-2.5 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800 border border-blue-200">
      {render_slot(@inner_block)}
    </span>
    """
  end
end
