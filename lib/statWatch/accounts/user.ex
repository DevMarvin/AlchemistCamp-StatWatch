defmodule StatWatch.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :name, :string
    field :username, :string

    has_many :profiles, StatWatch.Core.Profile, on_delete: :delete_all
    has_one :credential, StatWatch.Accounts.Credential, on_delete: :delete_all
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username])
    |> validate_required([:name, :username])
    |> unique_constraint(:username)
  end
end
