defmodule HapWeb.Layouts do
  @moduledoc false

  use HapWeb, :html

  embed_templates("layouts/*")
end
