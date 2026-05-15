defmodule TagIpWeb.ModeleTraceurLive.Form do
  use TagIpWeb, :live_view

  alias AshPhoenix.Form
  alias TagIp.Resources.ModeleTraceur

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
      Form.for_create(ModeleTraceur, :create, as: "modele_traceur")
      |> to_form()

    socket
    |> assign(:page_title, "Nouveau modèle de traceur")
    |> assign(:form, form)
    |> assign(:modele, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    modele = Ash.get!(ModeleTraceur, id, domain: TagIp.TagIp)

    form =
      Form.for_update(modele, :update, as: "modele_traceur")
      |> to_form()

    socket
    |> assign(:page_title, "Modifier le modèle #{modele.nom}")
    |> assign(:form, form)
    |> assign(:modele, modele)
  end

  @impl true
  def handle_event("validate", %{"modele_traceur" => params}, socket) do
    form =
      socket.assigns.form.source
      |> Form.validate(params)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"modele_traceur" => params}, socket) do
    sanitized_params =
      params
      |> Map.update("alimentations_compatibles", [], &String.split(&1, ",", trim: true))
      |> Map.update("types_vehicule_compatibles", [], &String.split(&1, ",", trim: true))
      |> Map.update("capteurs_supportes", [], &String.split(&1, ",", trim: true))

    case Form.submit(socket.assigns.form.source,
           params: %{"modele_traceur" => sanitized_params}
         ) do
      {:ok, _modele} ->
        message =
          if socket.assigns.modele,
            do: "Modèle de traceur modifié avec succès.",
            else: "Modèle de traceur créé avec succès."

        TagIp.Notification.broadcast({:notification, :info, message})

        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/modeles")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end
end
