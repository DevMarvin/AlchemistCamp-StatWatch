defmodule StatWatchWeb.ProfileController do
    use StatWatchWeb, :controller
  
    alias StatWatch.Core
    alias StatWatch.Core.Profile
    plug :logged_in_user when not action in [:new, :create, :show]
    plug :correct_user when action in[:edit, :update, :delete]
  
    def index(%{assigns: %{admin_user: true}} = conn, _params) do
      profiles = Core.list_profiles()
      render(conn, "index.html", profiles: profiles)
    end

    def index(%{assigns: %{current_user: user}} = conn, _params) do
      profiles = Core.list_profiles(user)
      if !!Core.list_profiles(user) == true do
      render(conn, "index.html", profiles: profiles)
      else 
      conn
      |> put_flash(:error, "You do not have any Profiles created!")
      |> redirect(to: Routes.profile_path(conn, :index))
      end  
    end
  
    def new(conn, _params) do
      changeset = Core.change_profile(%Profile{})
      render(conn, "new.html", changeset: changeset)
    end
  
    def create(%{assigns: %{current_user: current}} = conn,
              %{"profile" => profile_params}) do   
      
      params = Map.put(profile_params, "user_id", current.id)

      case Core.create_profile(params) do
        {:ok, profile} ->
          StatWatch.fetch_stats_and_save(profile)          
          conn
          |> put_flash(:info, "Profile created successfully.")
          |> redirect(to: Routes.profile_path(conn, :show, profile.name))
  
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    end
  
    def show(conn, %{"id" => name}) do
      profile = Core.get_profile_by_name(name)
      render(conn, "show.html", profile: profile)
    end
  
    def edit(conn, %{"id" => name}) do
      profile = Core.get_profile_by_name(name)
      changeset = Core.change_profile(profile)
      render(conn, "edit.html", profile: profile, changeset: changeset)
    end
  
    def update(%{assigns: %{current_user: current}} = conn,
               %{"id" => name, "profile" => profile_params}) do
      profile = Core.get_profile_by_name(name)
      params = Map.put_new(profile_params, "user_id", current.id)
  
      case Core.update_profile(profile, params) do
        {:ok, profile} ->
          conn
          |> put_flash(:info, "Profile updated successfully.")
          |> redirect(to: Routes.profile_path(conn, :show, profile.name))
  
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", profile: profile, changeset: changeset)
      end
    end
  
    def delete(conn, %{"id" => name}) do
      {:ok, _profile} = Core.delete_by_name(name)
  
      conn
      |> put_flash(:info, "Profile deleted successfully.")
      |> redirect(to: Routes.profile_path(conn, :index))
    end

    defp correct_user(%{assigns: %{current_user: current, admin_user: admin}, 
                      params: %{"id" => name}} = conn, _params) do

      redirect_user = if current, do: Routes.profile_path(conn, :index), else: "/"
      profile = Core.get_profile_by_name(name)

      if profile.user_id == current.id || admin do
        conn
      else
        conn
        |> put_flash(:error, "You do not have access to that page")
        |> redirect(to: redirect_user) 
        |> halt() 
      end                  
    end
  end
  