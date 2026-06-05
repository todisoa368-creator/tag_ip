defmodule TagIp.Repo.Migrations.AddVoltageToTrackableTypes do
  use Ecto.Migration

  def up do
    alter table(:trackable_types) do
      add :voltage_min, :float
      add :voltage_max, :float
    end
  end

  def down do
    alter table(:trackable_types) do
      remove :voltage_min
      remove :voltage_max
    end
  end
end
