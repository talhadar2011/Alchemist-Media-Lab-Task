defmodule TakeHomeTaskWeb.CampaignLive.Show do
  use TakeHomeTaskWeb, :live_view

  alias TakeHomeTask.Campaigns

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Campaign {@campaign.id}
        <:subtitle>This is a campaign record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/campaign"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/campaign/#{@campaign}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit campaign
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@campaign.name}</:item>
        <:item title="Daily budget">{@campaign.daily_budget}</:item>
        <:item title="Status">{@campaign.status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Campaign")
     |> assign(:campaign, Campaigns.get_campaign!(id))}
  end
end
