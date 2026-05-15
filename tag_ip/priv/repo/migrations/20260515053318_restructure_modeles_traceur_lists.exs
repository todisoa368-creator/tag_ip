defmodule TagIp.Repo.Migrations.RestructureModelesTraceurLists do
  use Ecto.Migration

  def change do
    create table(:types_vehicule, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :slug, :string, null: false
      add :label, :string, null: false
      timestamps()
    end

    create unique_index(:types_vehicule, [:slug])

    create table(:alimentations, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :slug, :string, null: false
      add :label, :string, null: false
      timestamps()
    end

    create unique_index(:alimentations, [:slug])

    create table(:capteurs, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :slug, :string, null: false
      add :label, :string, null: false
      timestamps()
    end

    create unique_index(:capteurs, [:slug])

    create table(:modeles_traceur_types_vehicule, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :modele_traceur_id, references(:modeles_traceur, type: :uuid, on_delete: :delete_all),
        null: false

      add :type_vehicule_id, references(:types_vehicule, type: :uuid, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create unique_index(:modeles_traceur_types_vehicule, [:modele_traceur_id, :type_vehicule_id])

    create table(:modeles_traceur_alimentations, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :modele_traceur_id, references(:modeles_traceur, type: :uuid, on_delete: :delete_all),
        null: false

      add :alimentation_id, references(:alimentations, type: :uuid, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create unique_index(:modeles_traceur_alimentations, [:modele_traceur_id, :alimentation_id])

    create table(:modeles_traceur_capteurs, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :modele_traceur_id, references(:modeles_traceur, type: :uuid, on_delete: :delete_all),
        null: false

      add :capteur_id, references(:capteurs, type: :uuid, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:modeles_traceur_capteurs, [:modele_traceur_id, :capteur_id])

    alter table(:modeles_traceur) do
      remove :types_vehicule_compatibles
      remove :alimentations_compatibles
      remove :capteurs_supportes
    end
  end
end
