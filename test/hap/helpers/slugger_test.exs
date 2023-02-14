defmodule Hap.Helpers.SluggerTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias Hap.Helpers.Slugger

  describe "generate_random_slug/0" do
    test "it returns a random string" do
      assert 5 =
               [
                 Slugger.generate_random_slug(),
                 Slugger.generate_random_slug(),
                 Slugger.generate_random_slug(),
                 Slugger.generate_random_slug(),
                 Slugger.generate_random_slug()
               ]
               |> Enum.uniq()
               |> Enum.count()
    end
  end
end
