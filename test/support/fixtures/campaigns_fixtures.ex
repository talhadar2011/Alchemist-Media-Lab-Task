defmodule TakeHomeTask.CampaignsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TakeHomeTask.Campaigns` context.
  """

  @doc """
  Generate a campaign.
  """
  def campaign_fixture(attrs \\ %{}) do
    {:ok, campaign} =
      attrs
      |> Enum.into(%{
        daily_budget: 42,
        name: "some name",
        status: "some status"
      })
      |> TakeHomeTask.Campaigns.create_campaign()

    campaign
  end
end
