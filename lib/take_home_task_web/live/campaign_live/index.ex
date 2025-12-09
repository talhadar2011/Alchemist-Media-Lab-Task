defmodule TakeHomeTaskWeb.CampaignLive.Index do
  use TakeHomeTaskWeb, :live_view

  alias TakeHomeTask.Campaigns

  @impl true
  def render(assigns) do
    IO.inspect(assigns.streams, label: "Assigns in CampaignLive.Index")

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
      <%= if @streams.campaign_collection != [] do %>
        <%!-- <.table id="campaign" rows={@streams.campaign_collection} row_click={fn {_id, campaign} -> JS.navigate(~p"/campaign/#{campaign}") end} >
          <:col :let={{_id, campaign}} label="Name">
            <%= campaign.name %>
          </:col>
          <:col :let={{_id, campaign}} label="Daily budget">
            <%= campaign.daily_budget %>
          </:col>
          <:col :let={{_id, campaign}} label="Status">
            <div class="flex justify-center items-center gap-2">
              <%= campaign.status %>
              <div class={
                "w-2 h-2 rounded " <>
                if campaign.status == "Active", do: "bg-green-400", else: "bg-red-400"
              }>
              </div>
            </div>
          </:col>
          <:action :let={{_id, campaign}}>
            <div class="sr-only">
              <.link navigate={~p"/campaign/#{campaign}"}>Show</.link>
            </div>
            <.link navigate={~p"/campaign/#{campaign}/edit"}>Edit</.link>
          </:action>
          <:action :let={{id, campaign}}>
            <.link phx-click={JS.push("delete", value: %{id: campaign.id}) |> hide("##{id}")} data-confirm="Are you sure?">
              Delete
            </.link>
          </:action>
        </.table> --%>
        <div id="grid" phx-update="stream" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
          <%= for {dom_id,item} <- @streams.campaign_collection do %>
            <div
              id={dom_id}
              class=" shadow-lg cursor-pointer h-50 m-2 p-4 border border-gray-300 rounded-xl bg-white text-black hover:scale-95 hover:shadow-2xl transition-transform"
              phx-click={JS.navigate(~p"/campaign/#{item.id}")}
            >
              <div class="flex justify-between">
                <div class="text-xl font-bold">{item.name}</div>
                <div class={
                  "text-white font-bold p-1 rounded " <>
                  if item.status == "Active", do: "bg-green-400", else: "bg-red-400"
                }>
                  <%= item.status %>
                </div>
                </div>
              <div class="mt-5 text-xl font-bold">
                Daily Budget: {item.daily_budget}
              </div>
              <button class=" cursor-pointer bg-red-400 p-2 rounded text-white mt-10" phx-click={JS.push("delete", value: %{id: item.id})
              |> hide("##{dom_id}")} data-confirm={"Are you sure?You want to delete "<>item.name}
              >Delete
              </button>
              <button class="w-17 cursor-pointer bg-blue-400 p-2 rounded text-white mt-10" phx-click={JS.navigate(~p"/campaign/#{item.id}/edit")}
              >Edit
              </button>
            </div>
          <% end %>
        </div>
      <% else %>
        <div class=" mt-10 flex justify-center items-center">
          <h1 class="text-2xl font-bold ">Wellcome here you can create new Campaigns.</h1>
        </div>
      <% end %>
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
