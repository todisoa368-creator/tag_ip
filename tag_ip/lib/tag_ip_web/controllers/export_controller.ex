defmodule TagIpWeb.ExportController do
  use TagIpWeb, :controller

  def modeles(conn, _params) do
    csv = TagIp.Export.modeles_csv()

    conn
    |> put_resp_content_type("text/csv; charset=utf-8")
    |> put_resp_header(
      "content-disposition",
      ~s(attachment; filename="modeles_traceurs_#{Date.utc_today()}.csv")
    )
    |> send_resp(200, csv)
  end

  def profils(conn, _params) do
    csv = TagIp.Export.profils_csv()

    conn
    |> put_resp_content_type("text/csv; charset=utf-8")
    |> put_resp_header(
      "content-disposition",
      ~s(attachment; filename="profils_montage_#{Date.utc_today()}.csv")
    )
    |> send_resp(200, csv)
  end
end
