defmodule TakeHomeTaskWeb.CampaignLive.Index do
  use TakeHomeTaskWeb, :live_view

  alias TakeHomeTask.Campaigns

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
         Campaigns
        <:actions>
          <.button variant="primary" navigate={~p"/campaign/new"}>
            <.icon name="hero-plus" /> New Campaign
          </.button>
        </:actions>
      </.header>
        <.table id="campaign" rows={@streams.campaign_collection} row_click={fn {_id, campaign} -> JS.navigate(~p"/campaign/#{campaign}") end} >
      <:col :let={{_id, campaign}} label="Name">{campaign.name}</:col>
      <:col :let={{_id, campaign}} label="Daily budget">{campaign.daily_budget}</:col>
      <:col :let={{_id, campaign}} label="Status">
        <div class="flex justify-center items-center gap-2">
        {campaign.status}
        <div class={"w-2 h-2 rounded " <>
        if campaign.status == "Active",
        do: "bg-green-400",
        else: "bg-red-400"}>
        </div>
        </div>
      </:col>
      <:action :let={{_id, campaign}}> <div class="sr-only"> <.link navigate={~p"/campaign/#{campaign}"}>Show</.link> </div>
      <.link navigate={~p"/campaign/#{campaign}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, campaign}}> <.link phx-click={JS.push("delete", value: %{id: campaign.id})
      |> hide("##{id}")} data-confirm="Are you sure?" > Delete </.link> </:action>
       </.table>


     </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Campaign")
     |> stream(:campaign_collection, list_campaign())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    campaign = Campaigns.get_campaign!(id)
    {:ok, _} = Campaigns.delete_campaign(campaign)

    {:noreply, stream_delete(socket, :campaign_collection, campaign)}
  end

  defp list_campaign() do
    Campaigns.list_campaign()
  end
end
