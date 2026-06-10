defmodule TagIp.Repo.Migrations.ChangeUsersRoleDefaultToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :role, :string, default: "user", null: false
    end

    execute "UPDATE users SET role = 'user' WHERE role IS NULL OR role = 'exploitation'"
  end
end
