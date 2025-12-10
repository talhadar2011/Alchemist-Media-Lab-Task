defmodule TakeHomeTaskWeb.CampaignLive.Show do
  use TakeHomeTaskWeb, :live_view

  alias TakeHomeTask.Campaigns
  import Phoenix.HTML

  @impl true
  def render(assigns) do
    IO.inspect(assigns, label: "Show Campaign Assigns")

    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        <div class="text-2xl font-bold">
          {@campaign.name}
        </div>
        <:actions>
          <.button navigate={~p"/campaign"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/campaign/#{@campaign}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit campaign
          </.button>
        </:actions>
      </.header>
      <div class="flex flex-col md:grid md:grid-cols-2 gap-6">
          <div class="p-6 grid gap-6  ">
            <h1 class="text-3xl font-bold">{@campaign.name} Preview Dashboard</h1>

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

            <button
              phx-click="start"
              class=" shadow-lg cursor-pointer rounded-2xl p-4 bg-white text-black"
            >
              <%= if @running do %>
                Stop Traffic
              <% else %>
                Start Traffic
              <% end %>
            </button>

            <div class="rounded-2xl shadow-lg p-4 bg-white text-black">
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
                      {event.time} - {String.capitalize(event.type)}
                    </div>
                  <% end %>
                <% else %>
                  <h1 class="text-gray-500 italic">No current Events Available</h1>
                <% end %>
              </div>
            </div>
          </div>
          <div class="p-6 bg-white shadow-lg rounded-lg">
            <h2 class="text-xl font-semibold mb-4">Traffic Chart</h2>

            <canvas
              id="traffic-chart"
              phx-hook="CampaignChart"
              phx-update="ignore"
              data-chart-data={Jason.encode!(@chart_data)}
              class="w-full h-64"
            />
          </div>

      </div>
    </Layouts.app>
    """
  end

  @impression_interval 500
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
     |> assign(:chart_data, default_chart_data())
     |> assign(:running, false)}
  end

  @impl true
  def handle_event("start", _params, socket) do
    if socket.assigns.running do
      {:noreply, assign(socket, :running, false)}
    else
      :timer.send_interval(@impression_interval, self(), :add_impression)
      :timer.send_interval(@click_interval, self(), :add_click)
      :timer.send_interval(@click_interval, self(), :add_ctr)

      Process.send_after(self(), :system_crash, 10_000)

      {:noreply, assign(socket, :running, true)}
    end
  end

  @impl true
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

      ctr = Float.round(clicks / impressions * 100, 2)

      chart_data = socket.assigns.chart_data
      timestamp = "#{length(chart_data.labels) * 3}s"

      new_chart_data =
        chart_data
        |> Map.update!(:labels, &(&1 ++ [timestamp]))
        |> Map.update!(:datasets, fn [ctr_ds] ->
          [
            %{ctr_ds | data: ctr_ds.data ++ [ctr]}
          ]
        end)

      {:noreply,
       socket
       |> assign(:ctr, ctr)
       |> assign(:chart_data, new_chart_data)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:system_crash, socket) do
    if socket.assigns.running do
      socket = assign(socket, :running, false)
      timestamp = DateTime.utc_now() |> Calendar.strftime("%H:%M:%S")
      new_event = %{type: "error", time: timestamp}

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

      socket =
        socket
        |> assign(:running, true)
        |> update(:events, fn events -> [new_event | events] end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp default_chart_data() do
    %{
      labels: ["0s"],
      datasets: [
        %{
          label: "CTR %",
          data: [0],
          borderColor: "rgb(255, 99, 132)",
          tension: 0.1
        }
      ]
    }
  end


end
