defmodule StatWatch.Repo do
  use Ecto.Repo,
    otp_app: :statWatch,
    adapter: Ecto.Adapters.Postgres
end
