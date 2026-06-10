defmodule TagIp.Repo.Migrations.AddBluetoothBleToModeleTraceur do
  use Ecto.Migration

  def change do
    alter table(:modeles_traceur) do
      add :bluetooth_ble, :boolean, default: false
    end
  end
end
