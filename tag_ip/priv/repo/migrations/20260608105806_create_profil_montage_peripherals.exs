defmodule TagIp.Repo.Migrations.CreateProfilMontagePeripherals do
  use Ecto.Migration

  def change do
    create table(:profil_montage_peripherals, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :profil_montage_id, references(:mounting_profiles, type: :uuid, on_delete: :delete_all),
        null: false

      add :peripheral_id, references(:peripherals, type: :uuid, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create unique_index(:profil_montage_peripherals, [:profil_montage_id, :peripheral_id])
    create index(:profil_montage_peripherals, [:peripheral_id])
  end
end
