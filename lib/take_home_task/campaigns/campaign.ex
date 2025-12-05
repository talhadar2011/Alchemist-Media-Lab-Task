defmodule TakeHomeTask.Campaigns.Campaign do
  use Ecto.Schema
  import Ecto.Changeset

  schema "campaign" do
    field :name, :string
    field :daily_budget, :integer
    field :status, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(campaign, attrs) do
    campaign
    |> cast(attrs, [:name, :daily_budget, :status])
    |> validate_required([:name, :daily_budget, :status])
  end
end
