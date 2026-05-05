defmodule TagIp.Repo do
  use AshPostgres.Repo, otp_app: :tag_ip, warn_on_missing_ash_functions?: false

  def init(_type, config) do
    config = Keyword.put(config, :pool_size, 10)
    {:ok, config}
  end

  def min_pg_version do
    %Version{major: 15, minor: 0, patch: 0}
  end
end
