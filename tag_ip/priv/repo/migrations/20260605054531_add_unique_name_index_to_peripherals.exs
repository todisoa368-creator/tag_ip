defmodule TagIp.Repo.Migrations.AddUniqueNameIndexToPeripherals do
  use Ecto.Migration

  def up do
    # Remove duplicates keeping the oldest record for each name
    execute """
    DELETE FROM peripherals
    WHERE id IN (
      SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY name ORDER BY inserted_at ASC) AS rn
        FROM peripherals
      ) sub
      WHERE sub.rn > 1
    )
    """

    create unique_index(:peripherals, [:name], name: "peripherals_unique_name_index")
  end

  def down do
    drop_if_exists unique_index(:peripherals, [:name], name: "peripherals_unique_name_index")
  end
end
