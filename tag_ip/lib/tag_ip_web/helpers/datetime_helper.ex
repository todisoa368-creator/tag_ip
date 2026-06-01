defmodule TagIpWeb.Helpers.DatetimeHelper do
  @timezone "Indian/Antananarivo"

  @spec format_datetime(
          nil
          | %{
              :__struct__ => DateTime | NaiveDateTime,
              :calendar => atom(),
              :day => pos_integer(),
              :hour => non_neg_integer(),
              :microsecond => {non_neg_integer(), non_neg_integer()},
              :minute => non_neg_integer(),
              :month => pos_integer(),
              :second => non_neg_integer(),
              :year => integer(),
              optional(:std_offset) => integer(),
              optional(:time_zone) => binary(),
              optional(:utc_offset) => integer(),
              optional(:zone_abbr) => binary()
            }
        ) :: binary()
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
