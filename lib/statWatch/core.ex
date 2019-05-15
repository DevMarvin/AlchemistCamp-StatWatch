defmodule StatWatch.Core do  
    import Ecto.Query, warn: false
    alias StatWatch.Repo
  
    alias StatWatch.Core.Profile

    def list_profiles do
      Repo.all(Profile)
    end

    def list_profiles(user) do
      Repo.all(where(Profile, user_id: ^user.id))
    end

    def get_profile!(id) do
      Repo.get!(Profile, id)
      |> Repo.preload([:stats, :user])
    end

    def get_profile_by_name(name) do
      Repo.get_by!(Profile, %{name: name})
      |> Repo.preload([:stats, :user])
    end    
  
    def create_profile(attrs \\ %{}) do
      %Profile{}
      |> Profile.changeset(attrs)
      |> Repo.insert()
    end
  
    def update_profile(%Profile{} = profile, attrs) do
      profile
      |> Profile.changeset(attrs)
      |> Repo.update()
    end
  
    def delete_profile(%Profile{} = profile) do
      Repo.delete(profile)
    end

    def delete_by_name(name) do
        Repo.get_by!(Profile, %{name: name})
        |> Repo.delete
    end
  
    def change_profile(%Profile{} = profile) do
      Profile.changeset(profile, %{})
    end
  end
  