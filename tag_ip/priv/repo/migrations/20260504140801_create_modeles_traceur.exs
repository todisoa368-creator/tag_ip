defmodule TagIp.Repo.Migrations.CreateModelesTraceur do
  use Ecto.Migration

  def change do
    create table(:modeles_traceur, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :nom, :string, size: 100, null: false
      add :reference, :string, size: 50, null: false
      add :types_vehicule_compatibles, {:array, :string}, default: []
      add :alimentations_compatibles, {:array, :string}, default: []
      add :capteurs_supportes, {:array, :string}, default: []
      add :description, :string, size: 500

      timestamps()
    end

    create unique_index(:modeles_traceur, [:reference])
  end
end
