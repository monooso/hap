defmodule Hap.Projects.EventQuery do
  @moduledoc """
  Struct used when filtering events.
  """

  defstruct name: "",
            message: "",
            sort_by: :inserted_at,
            sort_order: :desc,
            tags: []
end
