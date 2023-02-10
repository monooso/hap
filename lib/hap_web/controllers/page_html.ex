defmodule HapWeb.PageHTML do
  @moduledoc false

  use HapWeb, :html

  embed_templates("page_html/*")
end
