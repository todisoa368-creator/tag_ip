defmodule TagIpWeb.Helpers.DatetimeHelper do
  @timezone "Indian/Antananarivo"

  def format_datetime(nil), do: ""

  def format_datetime(%DateTime{} = datetime) do
    datetime
    |> DateTime.shift_zone!(@timezone, Tz.TimeZoneDatabase)
    |> Calendar.strftime("%d/%m/%Y %H:%M")
  end

  def format_datetime(%NaiveDateTime{} = naive) do
    naive
    |> DateTime.from_naive!("Etc/UTC")
    |> format_datetime()
  end
end
