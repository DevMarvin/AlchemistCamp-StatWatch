defmodule StatWatch.Core.Profile do
  use Ecto.Schema
  import Ecto.Changeset
  alias StatWatch.Core.{Profile, Stat}
  alias StatWatch.Accounts.User

  schema "profiles" do
    field :name, :string
    field :url, :string
    field :twitter, :string
    field :youtube, :string

    belongs_to :user, User
    has_many :stats, Stat, on_delete: :delete_all
  end

  def changeset(%Profile{} = profile, attrs) do
    profile
    |> cast(attrs, [:name, :url, :twitter, :youtube, :user_id])
    |> validate_required([:name, :user_id])
    |> unique_constraint(:name)
    |> foreign_key_constraint(:user_id)
  end
end
