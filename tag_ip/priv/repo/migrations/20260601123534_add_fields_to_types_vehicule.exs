defmodule TagIp.Repo.Migrations.AddFieldsToTypesVehicule do
  use Ecto.Migration

  def change do
    alter table(:types_vehicule) do
      add :voltage_min, :float, comment: "Tension minimale recommandée (V)"
      add :voltage_max, :float, comment: "Tension maximale recommandée (V)"
      add :inputs_requis, :integer, comment: "Nombre d'entrées numériques minimum requis"
      add :outputs_requis, :integer, comment: "Nombre de sorties minimum requis"
    end
  end
end
