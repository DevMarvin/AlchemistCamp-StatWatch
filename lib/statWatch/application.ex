defmodule StatWatch.Application do

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      StatWatch.Repo,
      StatWatchWeb.Endpoint,
      worker(StatWatch.Scheduler, [])
    ]

    opts = [strategy: :one_for_one, name: StatWatch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  
  def config_change(changed, _new, removed) do
    StatWatchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
