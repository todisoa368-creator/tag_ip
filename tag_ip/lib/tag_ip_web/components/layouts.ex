defmodule TagIpWeb.Layouts do
  @moduledoc """
  Ce module gère les layouts pour l'application TAG-Monitor de Tag-IP.
  """
  use TagIpWeb, :html

  embed_templates "layouts/*"

  # --- Layout APP ---
  attr :current_scope, :any, default: nil
  attr :flash, :map, required: true
  slot :inner_block, required: true
  def app(assigns)

  # --- Layout ROOT ---
  attr :current_scope, :any, default: nil
  def root(assigns)

  # --- FLASH GROUP ---
  # On ne définit l'attribut :flash qu'UNE SEULE FOIS ici
  attr :id, :string, default: "flash-group"
  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end

  def active_nav?(assigns, section) do
    case {assigns[:view_module], section} do
      {TagIpWeb.DashboardLive.Index, :dashboard} -> true
      {TagIpWeb.ProfilMontageLive.Index, :profils} -> true
      {TagIpWeb.ProfilMontageLive.Show, :profils} -> true
      {TagIpWeb.ProfilMontageLive.Form, :profils} -> true
      {TagIpWeb.ComparaisonLive.Index, :comparaison} -> true
      {TagIpWeb.ComparaisonLive.Admin, :comparaison} -> true
      {TagIpWeb.ModeleTraceurLive.Index, :modeles} -> true
      {TagIpWeb.ModeleTraceurLive.Show, :modeles} -> true
      {TagIpWeb.ModeleTraceurLive.Form, :modeles} -> true
      {TagIpWeb.ReferenceLive.Index, :referentiels} -> true
      {TagIpWeb.CompatibiliteLive.Index, :compatibilites} -> true
      {TagIpWeb.CompatibiliteLive.Show, :compatibilites} -> true
      _ -> false
    end
  end
end
