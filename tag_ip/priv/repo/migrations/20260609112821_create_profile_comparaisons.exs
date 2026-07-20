defmodule TagIp.Repo.Migrations.CreateProfileComparaisons do
  use Ecto.Migration

  def change do
    create table(:profile_comparaisons, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :feature_slugs, {:array, :string}, null: false, default: []
      add :peripheral_ids, {:array, :uuid}, null: false, default: []
      add :compatible_tracker_ids, {:array, :uuid}, null: false, default: []
      add :user_id, :uuid, null: true

      timestamps(type: :utc_datetime)
    end

    create index(:profile_comparaisons, [:user_id])
  end
end
