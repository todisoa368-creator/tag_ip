defmodule TagIp.Repo.Migrations.CreateProfilsMontage do
  use Ecto.Migration

  def change do
    create table(:profils_montage, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :nom, :string, size: 100, null: false
      add :type_vehicule, :string, size: 50, null: false
      add :alimentation, :string, size: 50, null: false
      add :capteurs, {:array, :string}, default: []
      add :description, :string, size: 500

      timestamps()
    end

    create index(:profils_montage, [:type_vehicule])
  end
end
