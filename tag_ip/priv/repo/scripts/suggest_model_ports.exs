#!/usr/bin/env elixir

Application.ensure_all_started(:logger)
Application.ensure_all_started(:tag_ip)

alias TagIp.Repo
alias TagIp.Resources.ModeleTraceur
alias TagIp.Resources.PortType
alias TagIp.Resources.Peripheral

out_dir = Path.join([File.cwd!(), "tmp"])
File.mkdir_p!(out_dir)
out_file = Path.join(out_dir, "suggested_model_ports.csv")

IO.puts("Loading port types and peripherals...")
port_types = PortType.read!() |> Enum.map(&{&1.id, &1}) |> Map.new()
peripherals = Peripheral.read!()

# unique port_type ids from peripherals
peripheral_port_type_ids = peripherals |> Enum.map(& &1.port_type_id) |> Enum.uniq()

IO.puts("Found #{length(peripherals)} peripherals, #{length(peripheral_port_type_ids)} unique port types")

modeles = ModeleTraceur.read!() |> Enum.map(fn m -> Ash.load!(m, [:model_ports]) end)
models_without_ports = Enum.filter(modeles, fn m -> Enum.empty?(m.model_ports || []) end)

IO.puts("Models without model_ports: #{length(models_without_ports)}")

rows =
  for m <- models_without_ports, pt_id <- peripheral_port_type_ids do
    pt = Map.get(port_types, pt_id)
    pin_label = "P_#{(pt && pt.slug) || String.slice(pt_id |> to_string(), 0, 6)}"
    reason = "inferred from peripherals with port_type"
    {
      m.id,
      Map.get(m, :nom) || Map.get(m, :name) || "",
      pin_label,
      pt_id,
      (pt && pt.label) || "",
      reason
    }
  end

headers = ["modele_id", "modele_nom", "pin_label", "port_type_id", "port_type_label", "reason"]

File.open!(out_file, [:write], fn file ->
  IO.write(file, Enum.join(headers, ",") <> "\n")
  Enum.each(rows, fn r ->
    row_list = if is_tuple(r), do: Tuple.to_list(r), else: r
    IO.write(file, (Enum.map(row_list, &to_string/1) |> Enum.join(",")) <> "\n")
  end)
end)

IO.puts("Wrote #{length(rows)} suggestions to #{out_file}")

IO.puts("Review the CSV and run a separate script to apply changes when ready.")
