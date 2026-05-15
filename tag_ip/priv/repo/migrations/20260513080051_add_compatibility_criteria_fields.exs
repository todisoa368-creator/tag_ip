defmodule TagIp.Repo.Migrations.AddCompatibilityCriteriaFields do
  use Ecto.Migration

  def change do
    alter table(:mounting_profiles) do
      add :inputs_requis, :integer
      add :analog_inputs_requis, :integer
      add :outputs_requis, :integer
      add :ip_rating, :text
      add :can_bus_requis, :boolean, default: false
      add :one_wire_requis, :boolean, default: false
      add :rs232_requis, :boolean, default: false
      add :rs485_requis, :boolean, default: false
      add :accelerometre_requis, :boolean, default: false
      add :buffer_requis, :integer
      add :montage_exterieur, :boolean, default: false
      add :antenne_deportee, :boolean, default: false
      add :ultra_low_power_requis, :boolean, default: false
    end

    alter table(:modeles_traceur) do
      add :nb_digital_inputs, :integer
      add :nb_analog_inputs, :integer
      add :nb_outputs, :integer
      add :ip_rating, :text
      add :can_bus, :boolean, default: false
      add :one_wire, :boolean, default: false
      add :rs232, :boolean, default: false
      add :rs485, :boolean, default: false
      add :accelerometer, :boolean, default: false
      add :buffer_memory, :integer
      add :antennes_externes, :boolean, default: false
      add :ultra_low_power, :boolean, default: false
      add :standby_current, :float
    end
  end
end
