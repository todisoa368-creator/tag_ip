defmodule TagIp.Repo.Migrations.DropTrackableCategories do
  use Ecto.Migration

  def change do
    drop table(:trackable_categories)
  end
end
