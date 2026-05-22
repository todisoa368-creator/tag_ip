defmodule TagIpWeb.UserLive.ResetPassword do
  use TagIpWeb, :live_view

  alias TagIp.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-[80vh] flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <div class="bg-white py-8 px-4 shadow-2xl border border-slate-100 sm:rounded-2xl sm:px-10">
          <div class="mb-8 text-center">
            <h2 class="text-2xl font-extrabold text-slate-900 tracking-tight">
              Réinitialiser le mot de passe
            </h2>
            <p class="mt-2 text-sm text-slate-500">
              Choisissez un nouveau mot de passe sécurisé.
            </p>
          </div>

          <.simple_form for={@form} id="reset_password_form" phx-submit="reset_password">
            <.input field={@form[:password]} type="password" label="Nouveau mot de passe" required />
            <.input
              field={@form[:password_confirmation]}
              type="password"
              label="Confirmer le nouveau mot de passe"
              required
            />
            <:actions>
              <.button phx-disable-with="Réinitialisation..." class="w-full">
                Changer le mot de passe
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(params, _session, socket) do
    token = params["token"]

    case Accounts.get_user_by_reset_password_token(token) do
      {user, _token} ->
        {:ok,
         socket
         |> assign(:token, token)
         |> assign(:user, user)
         |> assign(:form, to_form(%{}, as: "user"))}

      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Le lien de réinitialisation est invalide ou a expiré.")
         |> push_navigate(to: ~p"/users/log-in")}
    end
  end

  def handle_event(
        "reset_password",
        %{"user" => %{"password" => password, "password_confirmation" => password_confirmation}},
        socket
      ) do
    user = socket.assigns.user

    case Accounts.update_user_password(user, %{
           "password" => password,
           "password_confirmation" => password_confirmation
         }) do
      {:ok, {_user, _tokens}} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Mot de passe modifié avec succès. Veuillez vous connecter avec votre nouveau mot de passe."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Erreur lors de la réinitialisation. Vérifiez vos informations.")
         |> push_navigate(to: ~p"/users/log-in")}
    end
  end
end
