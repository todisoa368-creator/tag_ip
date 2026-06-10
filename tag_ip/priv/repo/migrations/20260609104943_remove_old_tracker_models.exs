defmodule TagIp.Repo.Migrations.RemoveOldTrackerModels do
  use Ecto.Migration

  def up do
    execute("""
      DELETE FROM model_ports
      WHERE modele_traceur_id IN (
        SELECT id FROM modeles_traceur WHERE reference IN ('TLT-FMC120', 'TLT-FMC640')
      )
    """)

    execute("""
      DELETE FROM model_features
      WHERE modele_traceur_id IN (
        SELECT id FROM modeles_traceur WHERE reference IN ('TLT-FMC120', 'TLT-FMC640')
      )
    """)

    execute("""
      DELETE FROM modeles_traceur_alimentations
      WHERE modele_traceur_id IN (
        SELECT id FROM modeles_traceur WHERE reference IN ('TLT-FMC120', 'TLT-FMC640')
      )
    """)

    execute("""
      DELETE FROM modeles_traceur_capteurs
      WHERE modele_traceur_id IN (
        SELECT id FROM modeles_traceur WHERE reference IN ('TLT-FMC120', 'TLT-FMC640')
      )
    """)

    execute("""
      DELETE FROM modeles_traceur_types_vehicule
      WHERE modele_traceur_id IN (
        SELECT id FROM modeles_traceur WHERE reference IN ('TLT-FMC120', 'TLT-FMC640')
      )
    """)

    execute("""
      DELETE FROM compatibilites
      WHERE modele_traceur_id IN (
        SELECT id FROM modeles_traceur WHERE reference IN ('TLT-FMC120', 'TLT-FMC640')
      )
    """)

    execute("""
      DELETE FROM modeles_traceur WHERE reference IN ('TLT-FMC120', 'TLT-FMC640')
    """)
  end

  def down do
  end
end
