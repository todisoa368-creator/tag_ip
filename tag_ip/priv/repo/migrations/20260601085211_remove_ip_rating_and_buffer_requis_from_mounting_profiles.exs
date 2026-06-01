defmodule TagIp.Repo.Migrations.RemoveIpRatingAndBufferRequisFromMountingProfiles do
  use Ecto.Migration

  def change do
    alter table(:mounting_profiles) do
      remove :ip_rating, :text
      remove :buffer_requis, :integer
    end
  end
end
