defmodule TagIp.Repo.Migrations.ChangeUserIdToIntegerInProfileComparaisons do
  use Ecto.Migration

  def change do
    # Postgres cannot cast uuid to integer, so we drop and re-add
    alter table(:profile_comparaisons) do
      remove :user_id
      add :user_id, :integer, null: true
    end
  end
end
