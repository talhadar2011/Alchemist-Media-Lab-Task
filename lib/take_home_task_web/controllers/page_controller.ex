defmodule TakeHomeTaskWeb.PageController do
  use TakeHomeTaskWeb, :controller
  alias TakeHomeTask.Campaigns

  def home(conn, _params) do
    conn
    |> assign(:list, list_campaign())
    |> render(:home)
  end

  defp list_campaign do
    Campaigns.list_active_campaigns()
  end
  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> render(:not_found)
  end
end
