defmodule HapWeb.UserOrganizationRegistrationLive do
  use HapWeb, :live_view

  alias Hap.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Create your organization
      </.header>

      <.simple_form for={@form} id="organization_form" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Organization name" required />

        <:actions>
          <.button phx-disable-with="Creating your organization..." class="w-full">Create your organization</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.create_organization_changeset(%{})

    socket =
      socket
      |> assign_changeset(changeset)
      |> assign_form()

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event(
        "save",
        %{"organization" => params},
        %{assigns: %{current_user: owner}} = socket
      ) do
    case Accounts.create_organization(owner, params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Organization created")
         |> push_redirect(to: ~p"/")}

      # How can we provide a meaningful error message if the "create member" step fails?
      {:error, :organization, %Ecto.Changeset{} = changeset, _changes} ->
        {:noreply,
         socket
         |> assign_changeset(changeset)
         |> assign_form()}
    end
  end

  defp assign_changeset(socket, changeset),
    do: assign(socket, changeset: changeset)

  defp assign_form(%{assigns: %{changeset: changeset}} = socket),
    do: assign(socket, form: to_form(changeset, as: "organization"))
end
