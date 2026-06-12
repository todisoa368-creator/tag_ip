defmodule TagIp.Repo.Migrations.AddOrganisationsAndAlimentationToProfiles do
  use Ecto.Migration

  def up do
    # 1. Create organisations table
    create table(:organisations, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :string
      timestamps()
    end

    create unique_index(:organisations, [:slug])

    # 2. Insert a default organisation so existing rows can reference it
    execute("""
    INSERT INTO organisations (id, name, slug, description, inserted_at, updated_at)
    VALUES (gen_random_uuid(), 'Tag-IP', 'tag-ip', 'Organisation par défaut', now(), now())
    """)

    # 3. Rename organization_id -> organisation_id on mounting_profiles
    rename table(:mounting_profiles), :organization_id, to: :organisation_id

    # 4. Make the column nullable (profiles can be created without an organisation)
    alter table(:mounting_profiles) do
      modify :organisation_id, :uuid, null: true
    end

    # 5. Add FK constraint to organisations
    alter table(:mounting_profiles) do
      modify :organisation_id, references(:organisations, type: :uuid, on_delete: :nilify_all)
    end

    # 6. Add alimentation_id FK column
    alter table(:mounting_profiles) do
      add :alimentation_id, references(:alimentations, type: :uuid, on_delete: :nilify_all)
    end

    create index(:mounting_profiles, [:alimentation_id])
  end

  def down do
    drop index(:mounting_profiles, [:alimentation_id])

    alter table(:mounting_profiles) do
      remove :alimentation_id
    end

    drop constraint(:mounting_profiles, "mounting_profiles_organisation_id_fkey")

    alter table(:mounting_profiles) do
      modify :organisation_id, :uuid, null: false
    end

    rename table(:mounting_profiles), :organisation_id, to: :organization_id

    drop table(:organisations)
  end
end
