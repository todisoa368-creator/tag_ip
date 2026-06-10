defmodule TagIp.Repo.Migrations.RemoveDuplicateFieldsFromMountingProfiles do
  use Ecto.Migration

  def change do
    alter table(:mounting_profiles) do
      add :bluetooth_ble_requis, :boolean, default: false
    end
  end
end
