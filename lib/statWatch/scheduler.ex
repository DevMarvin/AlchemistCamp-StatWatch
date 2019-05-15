defmodule StatWatch.Scheduler do
    use GenServer
  
    #@full_day 24 * 60 * 60 * 1000
  
    def start_link do
      GenServer.start_link(__MODULE__, %{})
    end
  
    def init(state) do
      handle_info(:work, state)
      {:ok, state}
    end
  
    def handle_info(:work, state) do
      schedule_work()      
      StatWatch.run
      {:noreply, state}
    end
  
    defp schedule_work() do
      Process.send_after(self(), :work, 10 * 60 * 1000)
    end
  end
  