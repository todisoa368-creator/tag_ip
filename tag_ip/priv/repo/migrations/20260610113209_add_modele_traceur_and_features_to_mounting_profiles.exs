defmodule TagIp.Repo.Migrations.AddModeleTraceurAndFeaturesToMountingProfiles do
  use Ecto.Migration

  def change do
    alter table(:mounting_profiles) do
      add :modele_traceur_id, references(:modeles_traceur, type: :uuid, on_delete: :nilify_all)
      add :feature_slugs, {:array, :text}, default: []
    end

    create index(:mounting_profiles, [:modele_traceur_id])
  end
end
