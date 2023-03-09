defmodule Hap.Helpers.Slugger do
  @moduledoc """
  Functions to generate short-ish URL slugs.

  Uses the Puid library to generate a string of alphanumeric characters. Capable of generating up
  to 20 million unique ID, with a 1 in a trillion chance of conflict.
  """

  use Puid, chars: :alphanum, risk: 1.0e15, total: 20.0e6

  @doc """
  Generates a random slug.
  """
  @spec generate_random_slug() :: String.t()
  def generate_random_slug(), do: generate()
end
