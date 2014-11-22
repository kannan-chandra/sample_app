require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup info" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, user: { name: "",
                               email: "user@invalid",
                               password: "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
  end

  test "valid signup info with account activation" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, user: { name: "Example User",
                               email: "user@invalid.com",
                               password: "foobar",
                               password_confirmation: "foobar" }
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    #try before activation
    log_in_as user
    assert_not is_logged_in?
    #invalid activation token
    get edit_account_activation_path("invalidness")
    assert_not is_logged_in?
    #invalid email
    get edit_account_activation_path(user.activation_token, email:"invalidness")
    assert_not is_logged_in?
    #valid everything!
    get edit_account_activation_path(user.activation_token, email:user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
