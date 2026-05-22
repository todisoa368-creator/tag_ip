defmodule TagIpWeb.ReferenceLive.Index do
  use TagIpWeb, :live_view

  alias Ash.Query
  alias TagIp.Resources.{Feature, Peripheral, PortType, TrackableType}

  @impl true
  def mount(_params, _session, socket) do
    port_types = PortType.read!() |> Enum.sort_by(& &1.label)
    features = Feature.read!() |> Enum.sort_by(& &1.label)

    peripherals =
      Peripheral
      |> Ash.Query.new()
      |> Query.load(:port_type)
      |> Ash.read!()
      |> Enum.sort_by(& &1.name)

    trackable_types = TrackableType.read!() |> Enum.sort_by(& &1.label)

    {:ok,
     socket
     |> assign(:page_title, "Référentiels")
     |> assign(:port_types, port_types)
     |> assign(:features, features)
     |> assign(:peripherals, peripherals)
     |> assign(:trackable_types, trackable_types)}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Référentiels")
     |> assign(:current_path, URI.parse(url).path)}
  end
end
