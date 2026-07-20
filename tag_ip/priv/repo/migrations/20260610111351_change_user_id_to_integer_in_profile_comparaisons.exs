defmodule TagIp.Repo.Migrations.ChangeUserIdToIntegerInProfileComparaisons do
  use Ecto.Migration

  def change do
    alter table(:profile_comparaisons) do
      remove :user_id
      add :user_id, :integer, null: true
    end
  end
end
