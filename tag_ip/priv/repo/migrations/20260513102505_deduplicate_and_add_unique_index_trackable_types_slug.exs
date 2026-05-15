defmodule TagIp.Repo.Migrations.DeduplicateAndAddUniqueIndexTrackableTypesSlug do
  use Ecto.Migration

  def up do
    execute """
            DELETE FROM trackable_types
            WHERE id NOT IN (
              SELECT id FROM (
                SELECT id, ROW_NUMBER() OVER (PARTITION BY slug ORDER BY inserted_at ASC) AS rn
                FROM trackable_types
              ) sub
              WHERE rn = 1
            )
            """,
            ""

    create unique_index(:trackable_types, [:slug])
  end

  def down do
    drop unique_index(:trackable_types, [:slug])
  end
end
