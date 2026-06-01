# lib/tag_ip/csv.ex
defmodule Csv do
  @moduledoc """
  Module utilitaire pour manipuler et nettoyer les données issues des fichiers CSV
  et des chaînes de caractères brutes de PostgreSQL.
  """

  @doc """
  Prend une chaîne brute comme "{ignition,engine_speed}" ou "{\\"ignition\\",\\"engine\\"}"
  et retourne une liste Elixir propre : ["ignition", "engine_speed"].

  Retourne une liste vide [] si la donnée est nil ou vide.
  """
  def clean_monitors(nil), do: []
  def clean_monitors(""), do: []

  def clean_monitors(monitors_str) when is_binary(monitors_str) do
    monitors_str
    |> String.replace(["{", "}"], "")
    |> String.replace("\"", "")
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
  end
end
