defmodule TagIp.Repo.Migrations.AddCascadeDeleteToCompatibilitesProfilMontage do
  use Ecto.Migration

  def change do
    drop constraint(:compatibilites, "compatibilites_profil_montage_id_fkey")

    alter table(:compatibilites) do
      modify :profil_montage_id,
             references(:mounting_profiles,
               column: :id,
               name: "compatibilites_profil_montage_id_fkey",
               type: :uuid,
               on_delete: :delete_all
             )
    end
  end
end
