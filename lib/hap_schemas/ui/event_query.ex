defmodule HapSchemas.Ui.EventQuery do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @type t() :: %__MODULE__{}

  embedded_schema do
    field :name, :string
  end

  @spec changeset(Changeset.t() | t(), map()) :: Changeset.t()
  def changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [:name])
  end
end
