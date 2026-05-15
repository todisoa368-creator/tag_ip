defmodule TagIpWeb.UserLive.ResetPassword do
  use TagIpWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <header class="text-center">
        <h1 class="text-lg font-semibold">Réinitialiser le mot de passe</h1>
      </header>

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
    """
  end

  def mount(params, _session, socket) do
    token = params["token"]
    {:ok, assign(socket, token: token, form: to_form(%{}, as: "user"))}
  end

  def handle_event(
        "reset_password",
        %{"user" => %{"password" => _password, "password_confirmation" => _conf}},
        socket
      ) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       "Mot de passe modifié avec succès. Veuillez vous connecter avec votre nouveau mot de passe."
     )
     |> push_navigate(to: ~p"/users/log-in")}
  end
end
