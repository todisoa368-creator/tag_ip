defmodule TagIpWeb.UserLive.Login do
  use TagIpWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <TagIpWeb.Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-[80vh] flex flex-col justify-center py-12 sm:px-6 lg:px-8">
        <div class="sm:mx-auto sm:w-full sm:max-w-md">
          <div class="bg-white py-8 px-4 shadow-2xl border border-slate-100 sm:rounded-2xl sm:px-10">
            <div class="mb-8 text-center">
              <h2 class="text-2xl font-extrabold text-slate-900 tracking-tight">
                Connexion TAG-Monitor
              </h2>
              <p class="mt-2 text-sm text-slate-500">
                Veuillez vous connecter pour accéder à l'application.
              </p>
            </div>

            <%!-- Formulaire Mot de Passe --%>
            <.simple_form
              for={@form}
              id="login_form_password"
              action={~p"/users/log-in"}
              phx-submit="submit_password"
              phx-trigger-action={@trigger_submit}
            >
              <.input
                field={@form[:email]}
                type="email"
                name="user[email]"
                label="Adresse Email"
                placeholder="votre@email.com"
              />

              <.input
                field={@form[:password]}
                type="password"
                name="user[password]"
                label="Mot de passe"
                placeholder="••••••••"
              />

              <div class="flex items-center justify-between">
                <div class="flex items-center">
                  <%!-- Utilisation d'un champ standard pour rester connecté --%>
                  <label class="flex items-center gap-2 text-sm text-slate-700">
                    <input
                      name="user[remember_me]"
                      type="checkbox"
                      value="true"
                      class="rounded border-slate-300 text-blue-600"
                    /> Rester connecté
                  </label>
                </div>
                <div class="text-sm">
                  <.link
                    href={~p"/users/reset_password"}
                    class="font-semibold text-blue-600 hover:underline"
                  >
                    Mot de passe oublié ?
                  </.link>
                </div>
              </div>

              <:actions>
                <.button
                  variant="primary"
                  phx-disable-with="Connexion..."
                  class="w-full"
                >
                  Se connecter →
                </.button>
              </:actions>
            </.simple_form>

            <div class="mt-6 text-center text-sm text-slate-500">
              Pas encore de compte ?
              <.link href={~p"/users/register"} class="font-semibold text-blue-600 hover:underline">
                Créer un compte
              </.link>
            </div>
          </div>
        </div>
      </div>
    </TagIpWeb.Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(%{"email" => "", "password" => ""}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end
end
