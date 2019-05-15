defmodule StatWatch.Core.Stat do
  use Ecto.Schema

  schema "stats" do
    field :youtube_subscribers, :integer
    field :youtube_videos, :integer
    field :youtube_views, :integer
    field :twitter_followers, :integer
    field :alexa_rank, :integer

    timestamps()

    belongs_to :profile, StatWatch.Core.Profile
  end
end
