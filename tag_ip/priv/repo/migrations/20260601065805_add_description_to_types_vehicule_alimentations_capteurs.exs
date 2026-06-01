defmodule TagIp.Repo.Migrations.AddDescriptionToTypesVehiculeAlimentationsCapteurs do
  use Ecto.Migration

  def change do
    alter table(:types_vehicule) do
      add :description, :text
    end

    alter table(:alimentations) do
      add :description, :text
    end

    alter table(:capteurs) do
      add :description, :text
    end
  end
end
