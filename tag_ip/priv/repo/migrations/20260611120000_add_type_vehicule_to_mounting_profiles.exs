defmodule TagIp.Repo.Migrations.AddTypeVehiculeToMountingProfiles do
  use Ecto.Migration

  def change do
    alter table(:mounting_profiles) do
      add :type_vehicule_id, references(:types_vehicule, type: :uuid, on_delete: :nilify_all)
    end

    create index(:mounting_profiles, [:type_vehicule_id])
  end
end
