defmodule StatWatch.Repo.Migrations.CreateStats do
  use Ecto.Migration

  def change do
    create table(:stats) do
      add :youtube_subscribers, :integer
      add :youtube_videos, :integer
      add :youtube_views, :integer
      add :twitter_followers, :integer
      add :alexa_rank, :integer
      add :profile_id, references(:profiles, on_delete: :nilify_all)

      timestamps()
    end
  end
end
