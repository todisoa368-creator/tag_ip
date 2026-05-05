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
    modele = Ash.get!(ModeleTraceur, id)

    form =
      Form.for_update(modele, :update, as: "modele_traceur")
      |> to_form()

    socket
    |> assign(:page_title, "Modifier le modèle #{modele.nom}")
    |> assign(:form, form)
    |> assign(:modele, modele)
  end


@impl true
def handle_event("next-step", _params, socket) do
  {:noreply, assign(socket, :step, socket.assigns.step + 1)}
end

@impl true
def handle_event("prev-step", _params, socket) do
  {:noreply, assign(socket, :step, socket.assigns.step - 1)}
end

# --- VALIDATION ET SAUVEGARDE (À mettre juste après) ---
@impl true
def handle_event("validate", %{"profil_montage" => params}, socket) do
  form =
    socket.assigns.form.source
    |> Form.validate(params)
    |> to_form()

  {:noreply, assign(socket, :form, form)}
end

@impl true
def handle_event("save", %{"profil_montage" => params}, socket) do
  case Form.submit(socket.assigns.form.source, params: params) do
    {:ok, _profil} ->
      {:noreply,
       socket
       |> put_flash(:info, "Profil enregistré avec succès")
       |> push_navigate(to: ~p"/profils")}

    {:error, form} ->
      {:noreply, assign(socket, :form, to_form(form))}
  end
end
end
