defmodule TakeHomeTaskWeb.CampaignLive.Show do
  use TakeHomeTaskWeb, :live_view

  alias TakeHomeTask.Campaigns

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@campaign.name}
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
      <div class="p-6 grid gap-6 max-w-4xl mx-auto">
        <h1 class="text-3xl font-bold">Campaign Preview Dashboard</h1>

        <div class="rounded-2xl shadow p-4">
          <div class="grid grid-cols-3 gap-4 text-center">
            <div>
              <p class="text-sm uppercase text-gray-500">Impressions</p>
              <p class="text-2xl font-bold">{@impressions}</p>
            </div>
            <div>
              <p class="text-sm uppercase text-gray-500">Clicks</p>
              <p class="text-2xl font-bold">{@clicks}</p>
            </div>
            <div>
              <p class="text-sm uppercase text-gray-500">CTR</p>
              <p class="text-2xl font-bold">{@ctr}%</p>
            </div>
          </div>
        </div>

        <button class="rounded-2xl p-4 bg-white text-black">
          button
        </button>

        <div class="rounded-2xl shadow p-4">
          <h2 class="text-xl font-semibold mb-3">Live Traffic Events</h2>
          <div class="max-h-64 overflow-auto grid gap-2"></div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    impressions = 0
    clicks = 0
    ctr = 0
    {:ok,
     socket
     |> assign(:page_title, "Show Campaign")
     |> assign(:campaign, Campaigns.get_campaign!(id))
     |> assign(%{
        impressions: impressions,
        clicks: clicks,
        ctr: ctr
      })
    }
  end
end
