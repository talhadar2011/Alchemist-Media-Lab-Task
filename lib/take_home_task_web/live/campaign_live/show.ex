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

        <div class="rounded-2xl shadow p-4 bg-white text-black">
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

        <button phx-click="start_timer" class=" cursor-pointer rounded-2xl p-4 bg-white text-black">
          <%= if @running do %>
            Stop
          <% else %>
            Start
          <% end %>
        </button>

      <div class="rounded-2xl shadow p-4 bg-white text-black">
      <h2 class="text-xl font-semibold mb-3 underline">Live Traffic Events</h2>
      <div class="max-h-64 overflow-auto grid gap-2">
        <%= if length(@events) > 0 do %>
          <%= for event <- @events do %>
            <div class={
            "p-2 rounded " <>
            cond do
              event.type == "click" -> "bg-gray-200 text-black"
              event.type == "back online" -> "bg-green-200 text-black"
              true -> "bg-red-400 text-white"
            end
          }>
              <%= event.time %> - <%= String.capitalize(event.type) %>
            </div>
          <% end %>
        <% else %>
          <h1 class="text-gray-500 italic">No current Events Available</h1>
        <% end %>
      </div>
    </div>

      </div>
    </Layouts.app>
    """
  end

  # 0.5 sec
  @impression_interval 500
  # 3 sec
  @click_interval 3000
  @impl true
  def mount(%{"id" => id}, _session, socket) do
    impressions = 0
    clicks = 0
    ctr = 0
    events = []

    {:ok,
     socket
     |> assign(:page_title, "Show Campaign")
     |> assign(:campaign, Campaigns.get_campaign!(id))
     |> assign(%{
       impressions: impressions,
       clicks: clicks,
       ctr: ctr,
       events: events
     })
     |> assign(:running, false)}
  end

  def handle_event("start_timer", _params, socket) do
    if socket.assigns.running do
      # Stop the timer manually
      {:noreply, assign(socket, :running, false)}
    else
      # Start timers
      :timer.send_interval(@impression_interval, self(), :add_impression)
      :timer.send_interval(@click_interval, self(), :add_click)
      :timer.send_interval(@click_interval, self(), :add_ctr)

      # Schedule auto-stop & restart after 10 sec
      Process.send_after(self(), :system_crash, 10_000)

      {:noreply, assign(socket, :running, true)}
    end
  end

  def handle_info(:add_impression, socket) do
    if socket.assigns.running do
      {:noreply, update(socket, :impressions, &(&1 + 1))}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:add_click, socket) do
    if socket.assigns.running do
      timestamp = DateTime.utc_now() |> Calendar.strftime("%H:%M:%S")
      new_event = %{type: "click", time: timestamp}

      {:noreply,
       socket
       |> update(:clicks, &(&1 + 1))
       |> update(:events, fn events -> [new_event | events] end)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:add_ctr, socket) do
    if socket.assigns.running and socket.assigns.clicks > 0 do
      impressions = socket.assigns.impressions
      clicks = socket.assigns.clicks

      ctr = Float.round(impressions / clicks, 2)

      {:noreply, assign(socket, :ctr, ctr)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:system_crash, socket) do
    if socket.assigns.running do
      socket = assign(socket, :running, false)
      timestamp = DateTime.utc_now() |> Calendar.strftime("%H:%M:%S")
      new_event = %{type: "error", time: timestamp}

      # Show flash notification
      {:noreply,
       socket
       |> update(:events, fn events -> [new_event | events] end)

       |> then(fn s ->
         Process.send_after(self(), :auto_restart, 3000)
         s
       end)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:auto_restart, socket) do
  if !socket.assigns.running do
      timestamp = DateTime.utc_now() |> Calendar.strftime("%H:%M:%S")
      new_event = %{type: "back online", time: timestamp}

    :timer.send_interval(@impression_interval, self(), :add_impression)
    :timer.send_interval(@click_interval, self(), :add_click)
    :timer.send_interval(@click_interval, self(), :add_ctr)

    socket =
      socket
      |> assign(:running, true)
      |> update(:events, fn events -> [new_event | events] end)

    {:noreply, socket}
  else
    {:noreply, socket}
  end
end

end
