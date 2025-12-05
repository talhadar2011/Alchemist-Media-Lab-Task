defmodule TakeHomeTask.CampaignsTest do
  use TakeHomeTask.DataCase

  alias TakeHomeTask.Campaigns

  describe "campaign" do
    alias TakeHomeTask.Campaigns.Campaign

    import TakeHomeTask.CampaignsFixtures

    @invalid_attrs %{name: nil, status: nil, daily_budget: nil}

    test "list_campaign/0 returns all campaign" do
      campaign = campaign_fixture()
      assert Campaigns.list_campaign() == [campaign]
    end

    test "get_campaign!/1 returns the campaign with given id" do
      campaign = campaign_fixture()
      assert Campaigns.get_campaign!(campaign.id) == campaign
    end

    test "create_campaign/1 with valid data creates a campaign" do
      valid_attrs = %{name: "some name", status: "some status", daily_budget: 42}

      assert {:ok, %Campaign{} = campaign} = Campaigns.create_campaign(valid_attrs)
      assert campaign.name == "some name"
      assert campaign.status == "some status"
      assert campaign.daily_budget == 42
    end

    test "create_campaign/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Campaigns.create_campaign(@invalid_attrs)
    end

    test "update_campaign/2 with valid data updates the campaign" do
      campaign = campaign_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status", daily_budget: 43}

      assert {:ok, %Campaign{} = campaign} = Campaigns.update_campaign(campaign, update_attrs)
      assert campaign.name == "some updated name"
      assert campaign.status == "some updated status"
      assert campaign.daily_budget == 43
    end

    test "update_campaign/2 with invalid data returns error changeset" do
      campaign = campaign_fixture()
      assert {:error, %Ecto.Changeset{}} = Campaigns.update_campaign(campaign, @invalid_attrs)
      assert campaign == Campaigns.get_campaign!(campaign.id)
    end

    test "delete_campaign/1 deletes the campaign" do
      campaign = campaign_fixture()
      assert {:ok, %Campaign{}} = Campaigns.delete_campaign(campaign)
      assert_raise Ecto.NoResultsError, fn -> Campaigns.get_campaign!(campaign.id) end
    end

    test "change_campaign/1 returns a campaign changeset" do
      campaign = campaign_fixture()
      assert %Ecto.Changeset{} = Campaigns.change_campaign(campaign)
    end
  end
end
