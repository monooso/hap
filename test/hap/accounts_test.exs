defmodule Hap.AccountsTest do
  use Hap.DataCase

  import Ecto.Changeset, only: [get_change: 2]

  alias Hap.Accounts
  alias Hap.Accounts.User
  alias Hap.Accounts.UserToken

  describe "get_user_by_email/1" do
    test "it does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "it returns the user if the email exists" do
      %{email: email, id: id} = insert(:user)
      assert %User{id: ^id} = Accounts.get_user_by_email(email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "it does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "it does not return the user if the password is not valid" do
      %{email: email} = insert(:user)
      refute Accounts.get_user_by_email_and_password(email, "invalid")
    end

    test "it returns the user if the email and password are valid" do
      %{email: email, id: id} = insert(:user, password: "so_secure")
      assert %User{id: ^id} = Accounts.get_user_by_email_and_password(email, "so_secure")
    end
  end

  describe "get_user!/1" do
    test "it raises if the id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "it returns the user with the given id" do
      %{id: id} = insert(:user)
      assert %User{id: ^id} = Accounts.get_user!(id)
    end
  end

  describe "register_user/1" do
    test "it requires the email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "it validates the email and password when given" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "it validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "it validates email uniqueness" do
      %{email: email} = insert(:user)
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "it registers users with a hashed password" do
      %{email: email} = build(:user)

      {:ok, user} = Accounts.register_user(%{email: email, password: "a valid password"})

      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "it returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end

    test "it allows fields to be set" do
      %{email: email} = build(:user)
      password = "a valid password"

      changeset = Accounts.change_user_registration(%User{}, %{email: email, password: password})

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_email/2" do
    test "it returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      password = "some_random_password"
      [password: password, user: insert(:user, password: password)]
    end

    test "it validates the email", %{password: password, user: user} do
      # Unchanged
      {:error, changeset} = Accounts.apply_user_email(user, password, %{})
      assert %{email: ["did not change"]} = errors_on(changeset)

      # Invalid
      {:error, changeset} = Accounts.apply_user_email(user, password, %{email: "not valid"})
      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)

      # Too long
      {:error, changeset} =
        Accounts.apply_user_email(user, password, %{email: String.duplicate("x", 161)})

      assert "should be at most 160 character(s)" in errors_on(changeset).email

      # Not unique
      %{email: email} = insert(:user)
      {:error, changeset} = Accounts.apply_user_email(user, password, %{email: email})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "it validates the current password", %{user: user} do
      %{email: email} = build(:user)

      {:error, changeset} = Accounts.apply_user_email(user, "invalid_password", %{email: email})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "it applies the email without persisting it", %{password: password, user: user} do
      %{email: email} = build(:user)

      {:ok, user} = Accounts.apply_user_email(user, password, %{email: email})

      assert user.email == email
      assert Accounts.get_user!(user.id).email != email
    end
  end

  describe "deliver_user_update_email_instructions/3" do
    setup do
      [user: insert(:user)]
    end

    test "it sends the token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = insert(:user)
      %{email: email} = build(:user)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      [email: email, token: token, user: user]
    end

    test "it updates the email with a valid token", %{user: user, token: token, email: email} do
      assert Accounts.update_user_email(user, token) == :ok

      changed_user = Repo.get!(User, user.id)

      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "it does not update the email with an invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "it does not update the email if the user email changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "it does not update the email if the token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])

      assert Accounts.update_user_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "it returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "it allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      password = "a valid password"
      [password: password, user: insert(:user, password: password)]
    end

    test "it validates the password", %{password: password, user: user} do
      # Invalid
      {:error, changeset} =
        Accounts.update_user_password(user, password, %{
          password: "invalid",
          password_confirmation: "invalid"
        })

      assert %{password: ["should be at least 12 character(s)"]} = errors_on(changeset)

      # Mismatched
      {:error, changeset} =
        Accounts.update_user_password(user, password, %{
          password: "perfectly_valid",
          password_confirmation: "imperfectly_valid"
        })

      assert %{password_confirmation: ["does not match password"]} = errors_on(changeset)

      # Too long
      {:error, changeset} =
        Accounts.update_user_password(user, password, %{password: String.duplicate("x", 73)})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "it validates the current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: "new valid password"})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "it updates the password", %{password: password, user: user} do
      {:ok, updated_user} =
        Accounts.update_user_password(user, password, %{password: "new valid password"})

      assert is_nil(updated_user.password)

      assert Accounts.get_user_by_email_and_password(updated_user.email, "new valid password")
    end

    test "it deletes all tokens for the given user", %{password: password, user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} = Accounts.update_user_password(user, password, %{password: "new valid password"})

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      [user: insert(:user)]
    end

    test "it generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: insert(:user).id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      [token: token, user: user]
    end

    test "it returns the user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "it does not return a user for an invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "it does not return a user for an expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_user_session_token/1" do
    test "it deletes the token" do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_user_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    setup do
      [user: insert(:user)]
    end

    test "it sends the token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end

  describe "confirm_user/1" do
    setup do
      user = insert(:user)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      [token: token, user: user]
    end

    test "it confirms the email with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "it does not confirm with an invalid token", %{user: user} do
      assert Accounts.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "it does not confirm the email if the token has expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      [user: insert(:user)]
    end

    test "it sends the token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = insert(:user)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      [token: token, user: user]
    end

    test "it returns the user with a valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "it does not return the user with an invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "it does not return the user if the token has expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      [user: insert(:user)]
    end

    test "it validates the password", %{user: user} do
      # Invalid
      {:error, changeset} =
        Accounts.reset_user_password(user, %{password: "nope", password_confirmation: "nope"})

      assert %{password: ["should be at least 12 character(s)"]} = errors_on(changeset)

      # Mismatched
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "a valid password",
          password_confirmation: "another valid password"
        })

      assert %{password_confirmation: ["does not match password"]} = errors_on(changeset)

      # Too long
      {:error, changeset} =
        Accounts.reset_user_password(user, %{password: String.duplicate("x", 73)})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "it updates the password", %{user: user} do
      {:ok, updated_user} = Accounts.reset_user_password(user, %{password: "new valid password"})

      assert is_nil(updated_user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "it deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2 for the User module" do
    test "it does not include the password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
