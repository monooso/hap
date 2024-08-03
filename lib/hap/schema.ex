defmodule Hap.Schema do
  @moduledoc """
  The base Hap schema.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset, except: [validate_required: 2]
      import Hap.Changeset
      import Hap.Schema

      alias Ecto.Changeset

      @timestamps_opts type: :utc_datetime
    end
  end
end
