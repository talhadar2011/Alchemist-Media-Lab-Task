defmodule TakeHomeTaskWeb.CampaignLiveTest do
  use TakeHomeTaskWeb.ConnCase

  import Phoenix.LiveViewTest
  import TakeHomeTask.CampaignsFixtures

  @create_attrs %{name: "some name", status: "some status", daily_budget: 42}
  @update_attrs %{name: "some updated name", status: "some updated status", daily_budget: 43}
  @invalid_attrs %{name: nil, status: nil, daily_budget: nil}
  defp create_campaign(_) do
    campaign = campaign_fixture()

    %{campaign: campaign}
  end

  describe "Index" do
    setup [:create_campaign]

    test "lists all campaign", %{conn: conn, campaign: campaign} do
      {:ok, _index_live, html} = live(conn, ~p"/campaign")

      assert html =~ "Listing Campaign"
      assert html =~ campaign.name
    end

    test "saves new campaign", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/campaign")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Campaign")
               |> render_click()
               |> follow_redirect(conn, ~p"/campaign/new")

      assert render(form_live) =~ "New Campaign"

      assert form_live
             |> form("#campaign-form", campaign: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#campaign-form", campaign: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/campaign")

      html = render(index_live)
      assert html =~ "Campaign created successfully"
      assert html =~ "some name"
    end

    test "updates campaign in listing", %{conn: conn, campaign: campaign} do
      {:ok, index_live, _html} = live(conn, ~p"/campaign")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#campaign_collection-#{campaign.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/campaign/#{campaign}/edit")

      assert render(form_live) =~ "Edit Campaign"

      assert form_live
             |> form("#campaign-form", campaign: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#campaign-form", campaign: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/campaign")

      html = render(index_live)
      assert html =~ "Campaign updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes campaign in listing", %{conn: conn, campaign: campaign} do
      {:ok, index_live, _html} = live(conn, ~p"/campaign")

      assert index_live |> element("#campaign_collection-#{campaign.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#campaign-#{campaign.id}")
    end
  end

  describe "Show" do
    setup [:create_campaign]

    test "displays campaign", %{conn: conn, campaign: campaign} do
      {:ok, _show_live, html} = live(conn, ~p"/campaign/#{campaign}")

      assert html =~ "Show Campaign"
      assert html =~ campaign.name
    end

    test "updates campaign and returns to show", %{conn: conn, campaign: campaign} do
      {:ok, show_live, _html} = live(conn, ~p"/campaign/#{campaign}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/campaign/#{campaign}/edit?return_to=show")

      assert render(form_live) =~ "Edit Campaign"

      assert form_live
             |> form("#campaign-form", campaign: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#campaign-form", campaign: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/campaign/#{campaign}")

      html = render(show_live)
      assert html =~ "Campaign updated successfully"
      assert html =~ "some updated name"
    end
  end
end
