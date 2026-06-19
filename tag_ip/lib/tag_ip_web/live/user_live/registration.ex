defmodule TagIpWeb.UserLive.Registration do
  use TagIpWeb, :live_view

  alias TagIp.Accounts
  alias TagIp.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-[80vh] flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <div class="bg-white py-8 px-4 shadow-2xl border border-slate-100 sm:rounded-2xl sm:px-10">
          <div class="mb-8 text-center">
            <h2 class="text-2xl font-extrabold text-slate-900 tracking-tight">
              Créer un compte
            </h2>
            <p class="mt-2 text-sm text-slate-500">
              Inscrivez-vous pour accéder à TAG-Monitor.
            </p>
          </div>

          <.form for={@form} id="registration_form" phx-submit="register">
            <.input
              field={@form[:email]}
              type="email"
              label="Adresse Email"
              placeholder="votre@email.com"
            />

            <.input
              field={@form[:password]}
              type="password"
              label="Mot de passe"
              placeholder="••••••••"
            />

            <.input
              field={@form[:password_confirmation]}
              type="password"
              label="Confirmer le mot de passe"
              placeholder="••••••••"
            />

            <.button variant="primary" phx-disable-with="Inscription..." class="w-full mt-6">
              Créer mon compte →
            </.button>
          </.form>

          <div class="mt-6 text-center text-sm text-slate-500">
            Déjà un compte ?
            <.link href={~p"/users/log-in"} class="font-semibold text-blue-600 hover:underline">
              Se connecter
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(Accounts.change_user_registration(%User{}), as: :user)

    {:ok, assign(socket, form: form)}
  end

  @impl true
  def handle_event("register", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, _user} ->
        socket =
          socket
          |> put_flash(:info, "Compte créé avec succès ! Bienvenue sur TAG-Monitor.")
          |> redirect(to: ~p"/users/log-in")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :user))}
    end
  end
end
