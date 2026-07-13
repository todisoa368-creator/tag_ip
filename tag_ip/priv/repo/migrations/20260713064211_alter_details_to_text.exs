defmodule TagIp.Repo.Migrations.AlterDetailsToText do
  use Ecto.Migration

  def change do
    alter table(:compatibilites) do
      modify :details, :text, from: {:string, size: 500}
    end
  end
end
