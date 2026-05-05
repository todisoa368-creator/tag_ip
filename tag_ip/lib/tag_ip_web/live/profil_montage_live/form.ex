defmodule TagIpWeb.ProfilMontageLive.Form do
  use TagIpWeb, :live_view

  alias AshPhoenix.Form
  alias TagIp.Resources.ProfilMontage

  @impl true
  def mount(_params, _session, socket) do
    # Initialisation des étapes pour le mode assistant selon les specs de ton chef
    {:ok,
     socket
     |> assign(:step, 1)
     |> assign(:total_steps, 4)}
  end

  @impl true
  def handle_params(params, url, socket) do
    path = URI.parse(url).path
    {:noreply,
     socket
     |> assign(:current_path, path)
     |> apply_action(socket.assigns.live_action, params)}
  end

  # --- GROUPE DES HANDLE_EVENT (Tous regroupés pour éviter les erreurs de compilation) ---

  @impl true
  def handle_event("next-step", _params, socket) do
    {:noreply, assign(socket, :step, socket.assigns.step + 1)}
  end

  @impl true
  def handle_event("prev-step", _params, socket) do
    {:noreply, assign(socket, :step, socket.assigns.step - 1)}
  end

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
  # Ajoute ce IO.inspect pour être SÛR que l'événement arrive ici
  IO.inspect(params, label: "PARAMÈTRES REÇUS")

  case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
    {:ok, _profil} ->
      {:noreply,
       socket
       |> put_flash(:info, "Profil enregistré !")
       |> push_navigate(to: ~p"/profils")} # Vérifie que cette route existe

    {:error, form} ->
      IO.inspect(form.errors, label: "ERREURS DE VALIDATION")
      {:noreply, assign(socket, form: to_form(form))}
  end
end
  # --- FONCTIONS PRIVÉES (apply_action) ---

  defp apply_action(socket, :new, _params) do
    # Utilisation du domaine TagIp pour la création
    form =
      Form.for_create(ProfilMontage, :create, as: "profil_montage", domain: TagIp.TagIp)
      |> to_form()

    socket
    |> assign(:page_title, "Nouveau profil de montage")
    |> assign(:form, form)
    |> assign(:profil, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # Récupération sécurisée du profil via l'ID
    profil = Ash.get!(ProfilMontage, id, domain: TagIp.TagIp)

    form =
      Form.for_update(profil, :update, as: "profil_montage")
      |> to_form()

    socket
    |> assign(:page_title, "Modifier le profil #{profil.name}")
    |> assign(:form, form)
    |> assign(:profil, profil)
  end
end
