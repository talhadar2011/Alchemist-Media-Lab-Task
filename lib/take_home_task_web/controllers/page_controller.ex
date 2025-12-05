defmodule TakeHomeTaskWeb.PageController do
  use TakeHomeTaskWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
