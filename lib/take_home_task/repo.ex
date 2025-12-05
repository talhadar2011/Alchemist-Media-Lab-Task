defmodule TakeHomeTask.Repo do
  use Ecto.Repo,
    otp_app: :take_home_task,
    adapter: Ecto.Adapters.SQLite3
end
