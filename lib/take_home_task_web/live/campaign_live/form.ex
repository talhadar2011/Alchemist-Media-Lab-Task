defmodule TakeHomeTaskWeb.CampaignLive.Form do
  use TakeHomeTaskWeb, :live_view

  alias TakeHomeTask.Campaigns
  alias TakeHomeTask.Campaigns.Campaign

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage campaign records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="campaign-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:daily_budget]} type="number" label="Daily budget" />
        <.input
        field={@form[:status]} type="select"
        options={[Active: "Active", Paused: "Paused"]}
        label="Status" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Campaign</.button>
          <.button navigate={return_path(@return_to, @campaign)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)

    socket
    |> assign(:page_title, "Edit Campaign")
    |> assign(:campaign, campaign)
    |> assign(:form, to_form(Campaigns.change_campaign(campaign)))
  end

  defp apply_action(socket, :new, _params) do
    campaign = %Campaign{}

    socket
    |> assign(:page_title, "New Campaign")
    |> assign(:campaign, campaign)
    |> assign(:form, to_form(Campaigns.change_campaign(campaign)))
  end

  @impl true
  def handle_event("validate", %{"campaign" => campaign_params}, socket) do
    changeset = Campaigns.change_campaign(socket.assigns.campaign, campaign_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"campaign" => campaign_params}, socket) do
    save_campaign(socket, socket.assigns.live_action, campaign_params)
  end

  defp save_campaign(socket, :edit, campaign_params) do
    case Campaigns.update_campaign(socket.assigns.campaign, campaign_params) do
      {:ok, campaign} ->

        {:noreply,
         socket
         |> put_flash(:info, "Campaign updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, campaign))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_campaign(socket, :new, campaign_params) do
    case Campaigns.create_campaign(campaign_params) do
      {:ok, campaign} ->
        {:noreply,
         socket
          |> put_flash(:info, "Campaign created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, campaign))}

        {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _campaign), do: ~p"/campaign"
  defp return_path("show", campaign), do: ~p"/campaign/#{campaign}"
end
