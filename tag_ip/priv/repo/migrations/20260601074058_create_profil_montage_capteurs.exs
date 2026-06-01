defmodule TagIp.Repo.Migrations.CreateProfilMontageCapteurs do
  use Ecto.Migration

  def change do
    create table(:profil_montage_capteurs, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :profil_montage_id, references(:mounting_profiles, type: :uuid, on_delete: :delete_all),
        null: false

      add :capteur_id, references(:capteurs, type: :uuid, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:profil_montage_capteurs, [:profil_montage_id, :capteur_id])
    create index(:profil_montage_capteurs, [:capteur_id])
  end
end
