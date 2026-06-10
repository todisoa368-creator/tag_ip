#!/usr/bin/env elixir

Application.ensure_all_started(:logger)
Application.ensure_all_started(:tag_ip)

alias TagIp.Repo
import Ecto.Query, only: [from: 2]

args = System.argv()
{opts, _, _} = OptionParser.parse(args, switches: [csv: :string, apply: :boolean])

csv = opts[:csv] || Path.join([File.cwd!(), "tmp", "suggested_model_ports.csv"])
do_apply = opts[:apply] || false

unless File.exists?(csv) do
  IO.puts("CSV not found: #{csv}")
  System.halt(1)
end

lines = File.read!(csv) |> String.split("\n", trim: true)
case lines do
  [] ->
    IO.puts("CSV is empty: #{csv}")
    System.halt(1)
  [header | rows] ->
    parsed =
      rows
      |> Enum.map(fn line ->
        case String.split(line, ",") do
          [modele_id, modele_nom, pin_label, port_type_id | _rest] ->
            {modele_id, modele_nom, pin_label, port_type_id}
          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    IO.puts("Read #{length(parsed)} rows from #{csv}")
    IO.puts("Sample:")
    Enum.take(parsed, 10) |> Enum.each(fn {m, n, p, pt} ->
      IO.puts("modele=#{m} nom=#{n} pin=#{p} port_type=#{pt}")
    end)

    unless do_apply do
      IO.puts("\nDry run. To apply insertions, re-run with --apply\nExample: mix run priv/repo/scripts/apply_model_ports_from_csv.exs --csv tmp/suggested_model_ports.csv --apply")
      System.halt(0)
    end

    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    {:ok, {ins, skip}} =
      Repo.transaction(fn ->
        Enum.reduce(parsed, {0, 0}, fn {modele_id, _nom, pin_label, port_type_id}, {acc_i, acc_s} ->
          case {Ecto.UUID.dump(modele_id), Ecto.UUID.dump(port_type_id)} do
            {{:ok, modele_db}, {:ok, port_db}} ->
              existing = Repo.one(from mp in "model_ports", where: mp.modele_traceur_id == ^modele_db and mp.port_type_id == ^port_db, select: count(mp.id)) || 0

              if existing > 0 do
                {acc_i, acc_s + 1}
              else
                {:ok, id_bin} = Ecto.UUID.dump(Ecto.UUID.generate())

                attrs = %{
                  id: id_bin,
                  modele_traceur_id: modele_db,
                  port_type_id: port_db,
                  pin_label: pin_label,
                  inserted_at: now,
                  updated_at: now
                }

                case Repo.insert_all("model_ports", [attrs]) do
                  {1, _} -> {acc_i + 1, acc_s}
                  _ -> {acc_i, acc_s}
                end
              end

            _ ->
              IO.puts("Skipping invalid UUIDs for modele=#{modele_id} port_type=#{port_type_id}")
              {acc_i, acc_s}
          end
        end)
      end)

    IO.puts("Inserted #{ins} new rows, skipped #{skip} existing rows")
end
