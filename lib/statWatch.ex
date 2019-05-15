defmodule StatWatch do
  import SweetXml
  alias StatWatch.Repo
  alias StatWatch.Core.Profile
  alias StatWatch.Core.Stat

  def run do
    for profile <- (Repo.all Profile) do
      profile
      |> Repo.preload(:stats)
      |> fetch_stats_and_save
    end
    |> save_all 
  end

  def fetch_stats_and_save(profile) do
    fetch_stats(profile)
      |> Enum.map(fn x -> force_int(x) end)
      |> save_to_db(profile)
  end  

  def column_names() do
    Enum.join ~w(DateTime Subscribers Videos Views), ", "
  end

  def fetch_stats(profile) do
    now = DateTime.to_string(%{DateTime.utc_now | microsecond: {0, 0}})

    alexa = if profile.url do
      %{body: body} = HTTPoison.get! "data.alexa.com/data?cli=10&url=#{profile.url}"
      body |> xpath(~x"//POPULARITY/@TEXT"s) || "unranked"
    end   

    twitter = if profile.twitter do
      %{body: body} = HTTPoison.get! "https://twitter.com/#{profile.twitter}"
      body
        |> Floki.attribute("li.ProfileNav-item--followers span", "data-count")
        |> Enum.at(0)
    end

    #default = %{subscriberCount: "unlisted", videoCount: "unlisted", viewCount: "unlisted"}

    youtube = %{subscriberCount: "unlisted", videoCount: "unlisted", viewCount: "unlisted"}
    #case HTTPoison.get! stats_url(profile.youtube) do
      #%{body: body} ->
        #case Poison.decode! body, keys: :atoms do
          #%{items: [%{statistics: stats} | _]} -> stats
          #_ -> default
        #end
      #_ -> default
    #end
    [
      now,
      youtube.subscriberCount,
      youtube.videoCount,
      youtube.viewCount,
      twitter,
      alexa
    ]
  end

  def force_int(x) when is_integer(x), do: x

  def force_int(x) when is_binary(x) do
    case Integer.parse(x) do
      {num, ""} -> num
      _ -> -1
    end  
  end

  def force_int(_x), do: -1

  def load_profiles(name) do
    Repo.get_by(Profile, %{name: name})
    |> Repo.preload(:stats)
  end

  def save_to_db([_, subs, videos, views, twitter, alexa], profile) do
    now = %{NaiveDateTime.utc_now | microsecond: {0, 0}}

    %{
      inserted_at: now,
      updated_at: now,
      youtube_subscribers: subs,
      youtube_videos: videos,
      youtube_views: views,
      twitter_followers: twitter,
      alexa_rank: alexa,
      profile_id: profile.id
    }
  end

  def save_all(saveable_map) do
    Repo.insert_all Stat, saveable_map
  end  

  def save_csv(row_of_stats, name) do
    row = row_of_stats |> Enum.join(", ")
    path = "priv/static/stats"
    filename = path <> name <> ".csv"

    unless File.exists?(filename) do
      File.mkdir_p!(path)
      File.write!(filename, column_names() <> "\n")
    end

    File.write!(filename, row <> "\n", [:append])
  end

  def stats_url(channel_id) do
    youtube_api_v3 = "https://www.googleapis.com/youtube/v3/"
    key = "key=" <> "AIzaSyBk93FS7ViCwR0E-bK2z9_-tha38wqk6A8"
    "#{youtube_api_v3}channels?id=#{channel_id}&#{key}&part=statistics, snippets"
  end
end
