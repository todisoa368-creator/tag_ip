defmodule TagIpWeb.UserLive.Login do
  use TagIpWeb, :live_view

  alias TagIp.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-[80vh] flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <div class="bg-white py-8 px-4 shadow-2xl border border-slate-100 sm:rounded-2xl sm:px-10">
          <div class="mb-8 text-center">
            <h2 class="text-2xl font-extrabold text-slate-900 tracking-tight">
              Connexion TAG-Monitor
            </h2>
            <p class="mt-2 text-sm text-slate-500">
              <%= if assigns[:current_scope] && @current_scope.user do %>
                Veuillez vous réauthentifier pour continuer.
              <% else %>
                Pas encore de compte ?
                <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-blue-600 hover:underline"
                >
                  S'inscrire
                </.link>
              <% end %>
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

          <div class="relative my-8">
            <div class="absolute inset-0 flex items-center" aria-hidden="true">
              <div class="w-full border-t border-slate-200"></div>
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-2 bg-white text-slate-500">Ou continuer avec</span>
            </div>
          </div>

          <%!-- Option Magic Link --%>
          <.form
            for={@form}
            id="login_form_magic"
            action={~p"/users/log-in"}
            phx-submit="submit_magic"
          >
            <input
              type="hidden"
              name="user[email]"
              value={Phoenix.HTML.Form.input_value(@form, :email)}
            />
            <.button
              type="submit"
              variant="outline"
              class="w-full"
            >
              Lien magique par email
            </.button>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # On met l'email par défaut directement ici
    default_email = "admin@tag-ip.com"
    form = to_form(%{"email" => default_email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  @impl true
  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    magic_link_min = TagIp.Accounts.UserToken.magic_link_validity_minutes()

    info =
      "Si votre email est dans notre système, vous recevrez un lien de connexion sous peu. Ce lien expire dans #{magic_link_min} minutes."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end
end
