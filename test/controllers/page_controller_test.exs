defmodule Ev3.PageControllerTest do
  use Ev3.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "<div id=\"elm-main\"></div>"
  end
  
end
