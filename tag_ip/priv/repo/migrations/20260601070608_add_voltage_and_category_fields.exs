defmodule TagIp.Repo.Migrations.AddVoltageAndCategoryFields do
  use Ecto.Migration

  def change do
    # Add voltage range to modele_traceur
    alter table(:modeles_traceur) do
      add :voltage_min, :float, comment: "Tension minimale supportée (V)"
      add :voltage_max, :float, comment: "Tension maximale supportée (V)"
    end

    # Add category to capteurs
    alter table(:capteurs) do
      add :category, :string,
        comment:
          "Catégorie de capteur: energy, safety, environment, driver, vehicle_status, connectivity"
    end

    # Add category to alimentations (voltage vs power_type)
    alter table(:alimentations) do
      add :category, :string, default: "voltage", comment: "Catégorie: voltage ou power_type"
    end
  end
end
