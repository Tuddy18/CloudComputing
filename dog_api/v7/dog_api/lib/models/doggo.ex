defmodule Doggos.Doggo do
  use Ecto.Schema

  @primary_key {:doggoId, :id, autogenerate: true}

  use Doggos.Models.Base

  @derive {Poison.Encoder, only: [:name, :age]}
  schema "doggos" do
    field :name, :string
    field :age, :integer
  end



end