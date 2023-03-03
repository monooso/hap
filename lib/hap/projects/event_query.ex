defmodule Hap.Projects.EventQuery do
  @moduledoc """
  Struct used when filtering events.
  """

  defstruct name: "",
            message: "",
            tags: []
end
