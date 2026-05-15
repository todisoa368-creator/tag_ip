defmodule TagIp.Accounts.UserNotifier do
  import Swoosh.Email

  alias TagIp.Mailer
  alias TagIp.Accounts.User

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"TagIp", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  AJOUTÉ : Cette fonction résout l'erreur UndefinedFunctionError.
  Elle redirige vers la bonne logique d'envoi selon l'état de l'utilisateur.
  """
  def deliver_instructions(user, url) do
    deliver_login_instructions(user, url)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    days = TagIp.Accounts.UserToken.change_email_validity_days()

    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    This link expires in #{days} days.

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    minutes = TagIp.Accounts.UserToken.magic_link_validity_minutes()

    deliver(user.email, "Log in instructions", """

    ==============================

    Hi #{user.email},

    You can log into your account by visiting the URL below:

    #{url}

    This link expires in #{minutes} minutes.

    If you didn't request this email, please ignore this.

    ==============================
    """)
  end

  defp deliver_confirmation_instructions(user, url) do
    minutes = TagIp.Accounts.UserToken.magic_link_validity_minutes()

    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    This link expires in #{minutes} minutes.

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    minutes = TagIp.Accounts.UserToken.magic_link_validity_minutes()

    deliver(user.email, "Réinitialisation de votre mot de passe", """

    ==============================

    Bonjour #{user.email},

    Vous pouvez réinitialiser votre mot de passe en visitant l'URL ci-dessous :

    #{url}

    Ce lien expire dans #{minutes} minutes.

    Si vous n'avez pas demandé ce changement, veuillez ignorer cet e-mail.

    ==============================
    """)
  end
end
