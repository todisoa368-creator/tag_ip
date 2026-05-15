defmodule TagIpWeb.PageControllerTest do
  use TagIpWeb.ConnCase

  test "GET / redirects to login when not authenticated", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 302)
    assert conn.halted
  end
end
