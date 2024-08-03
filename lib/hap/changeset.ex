defmodule Hap.Changeset do
  @moduledoc """
  Helper functions for working with Ecto changesets.
  """

  @doc """
  Applies the given `params` as changes on the `data` according to the set of `permitted` keys.
  Returns a changeset.

  Overrides the `messages` option to simplify the process of using custom messages for cast errors.
  See the `Ecto.Changeset.cast/4` documentation for information about the other supported options,
  and casting in general.
  """
  def cast_with_messages(data, params, permitted, opts \\ []) do
    messages = Keyword.get(opts, :messages, [])
    message_func = fn field, _meta -> Keyword.get(messages, field, "The format is invalid") end

    Ecto.Changeset.cast(data, params, permitted, Keyword.put(opts, :message, message_func))
  end

  @doc """
  Validates that the given fields are present in the given changeset.

  Overrides Ecto.Changeset.validate_required/2 to provide a more user-friendly default message.
  *Does not* override the Ecto.Changeset.validate_required/3 function, so it's still possible to
  provide a custom message if needed.

  ## Example

    validate_required(changeset, [:email, :name])

  """
  @spec validate_required(Ecto.Changeset.t(), atom() | list(atom())) ::
          Ecto.Changeset.t()
  def validate_required(changeset, fields) when not is_nil(fields) do
    fields = List.wrap(fields)

    Enum.reduce(fields, changeset, fn field, changeset ->
      message = generate_required_message(field)
      Ecto.Changeset.validate_required(changeset, field, message: message)
    end)
  end

  @spec generate_required_message(atom()) :: String.t()
  defp generate_required_message(field) do
    normalized_field = field |> Atom.to_string() |> String.replace_suffix("_id", "")
    "Please specify the #{normalized_field}"
  end
end
