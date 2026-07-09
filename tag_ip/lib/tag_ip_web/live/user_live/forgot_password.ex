defmodule TagIpWeb.UserLive.ForgotPassword do
  use TagIpWeb, :live_view

  alias TagIp.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm mt-10">
      <header class="text-center">
        <h1 class="text-2xl font-semibold tracking-tight text-gray-900">
          Mot de passe oublié ?
        </h1>
        <p class="mt-2 text-sm text-gray-600">
          Entrez votre email pour recevoir un lien de réinitialisation.
        </p>
      </header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Envoi en cours..." class="w-full">
            Envoyer les instructions
          </.button>
        </:actions>
      </.simple_form>

      <p class="mt-4 text-center text-sm">
        <.link href={~p"/users/log-in"} class="font-semibold text-blue-600 hover:underline">
          Retour à la connexion
        </.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{"email" => ""}))}
  end

  def handle_event("send_email", %{"email" => email}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    expiry_min = TagIp.Accounts.UserToken.magic_link_validity_minutes()

    info =
      "Si votre email existe dans notre base, vous recevrez bientôt un lien de réinitialisation. Ce lien expire dans #{expiry_min} minutes."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/users/log-in")}
  end
end
