defmodule TagIp.Repo.Migrations.AddPortTypesFeaturesPeripherals do
  use Ecto.Migration

  def change do
    # Add brand column to modeles_traceur
    alter table(:modeles_traceur) do
      add :brand, :text
    end

    # --- port_types ---
    create table(:port_types, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :slug, :string, null: false
      add :label, :string, null: false
      add :description, :text
      timestamps()
    end

    create unique_index(:port_types, [:slug])

    # --- features ---
    create table(:features, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :slug, :string, null: false
      add :label, :string, null: false
      add :description, :text
      timestamps()
    end

    create unique_index(:features, [:slug])

    # --- model_features (join table: modeles_traceur <-> features) ---
    create table(:model_features, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :modele_traceur_id, references(:modeles_traceur, type: :uuid, on_delete: :delete_all),
        null: false

      add :feature_id, references(:features, type: :uuid, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:model_features, [:modele_traceur_id, :feature_id])

    # --- model_ports (physical pins/ports on each tracker model) ---
    create table(:model_ports, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :modele_traceur_id, references(:modeles_traceur, type: :uuid, on_delete: :delete_all),
        null: false

      add :port_type_id, references(:port_types, type: :uuid, on_delete: :delete_all), null: false
      add :pin_label, :string, null: false
      timestamps()
    end

    create index(:model_ports, [:modele_traceur_id])
    create index(:model_ports, [:port_type_id])

    # --- peripherals ---
    create table(:peripherals, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :port_type_id, references(:port_types, type: :uuid, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :description, :text
      timestamps()
    end

    create index(:peripherals, [:port_type_id])
  end
end
