defmodule TakeHomeTask.Repo.Migrations.CreateCampaign do
  use Ecto.Migration
  def change do
    create table(:campaign) do
      add :name, :string
      add :daily_budget, :integer
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
