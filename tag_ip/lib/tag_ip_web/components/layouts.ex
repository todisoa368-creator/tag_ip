defmodule TagIpWeb.Layouts do
  @moduledoc """
  Ce module gère les layouts pour l'application TAG-Monitor de Tag-IP.
  """
  use TagIpWeb, :html

  # 1. On charge les fichiers .html.heex (root et app)
  # C'est cette ligne qui doit rester en haut.
  embed_templates "layouts/*"
  slot :inner_block, required: true
  attr :flash, :map, required: true

  @doc """
  Rendu du layout 'app'.
  On ne met plus le code HTML ici, il est maintenant dans app.html.heex.
  """
  def app(assigns)

  @doc """
  Rendu du layout 'root'.
  """
  def root(assigns)

  @doc """
  Affiche le groupe de notifications (flash).
  Cette fonction reste ici car elle est utilisée par les composants de base.
  """
  attr :flash, :map, required: true, doc: "le dictionnaire des messages flash"
  attr :id, :string, default: "flash-group", doc: "id optionnel du conteneur"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("Erreur de connexion")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Tentative de reconnexion")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Une erreur est survenue !")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Tentative de reconnexion")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
