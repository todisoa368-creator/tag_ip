defmodule TagIpWeb.OrganisationLive.Form do
  use TagIpWeb, :live_view

  alias AshPhoenix.Form
  alias TagIp.Resources.Organisation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, url, socket) do
    path = URI.parse(url).path

    {:noreply,
     socket
     |> assign(:current_path, path)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    form =
      Form.for_create(Organisation, :create, as: "organisation")
      |> to_form()

    socket
    |> assign(:page_title, "Nouvelle organisation")
    |> assign(:form, form)
    |> assign(:organisation, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    organisation = Ash.get!(Organisation, id, domain: TagIp.TagIp)

    form =
      Form.for_update(organisation, :update, as: "organisation")
      |> to_form()

    socket
    |> assign(:page_title, "Modifier l'organisation #{organisation.name}")
    |> assign(:form, form)
    |> assign(:organisation, organisation)
  end

  @impl true
  def handle_event("validate", %{"organisation" => params}, socket) do
    form =
      socket.assigns.form.source
      |> Form.validate(params)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"organisation" => params}, socket) do
    case Form.submit(socket.assigns.form.source, params: params) do
      {:ok, _organisation} ->
        message =
          if socket.assigns.organisation,
            do: "Organisation modifiée avec succès.",
            else: "Organisation créée avec succès."

        TagIp.Notification.broadcast({:notification, :info, message})

        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/organisations")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  def handle_event("save", _params, socket) do
    case Form.submit(socket.assigns.form.source) do
      {:ok, _organisation} ->
        message =
          if socket.assigns.organisation,
            do: "Organisation modifiée avec succès.",
            else: "Organisation créée avec succès."

        TagIp.Notification.broadcast({:notification, :info, message})

        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/organisations")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end
end
