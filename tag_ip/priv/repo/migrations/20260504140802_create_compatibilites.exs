defmodule TagIp.Repo.Migrations.CreateCompatibilites do
  use Ecto.Migration

  def change do
    create table(:compatibilites, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :profil_montage_id, references(:profils_montage, type: :uuid, on_delete: :delete_all),
        null: false

      add :modele_traceur_id, references(:modeles_traceur, type: :uuid, on_delete: :delete_all),
        null: false

      add :score_compatibilite, :integer, null: false, default: 0
      add :details, :string, size: 500

      timestamps()
    end

    create index(:compatibilites, [:profil_montage_id])
    create index(:compatibilites, [:modele_traceur_id])

    create unique_index(:compatibilites, [:profil_montage_id, :modele_traceur_id],
             name: :unique_compatibilite
           )
  end
end
