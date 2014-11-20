require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), user: { name:"",
                            email: "blah@",
                            password: "foo",
                            password_confirmation:"bar" }
    assert_template "users/edit"
  end

  test "successful edit" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    follow_redirect!
    assert_template "users/edit"
    name = "Michaelangelo"
    email = "mickey@mike.mic"
    patch user_path(@user), user: { name: name,
                            email: email,
                            password: "",
                            password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @user
    follow_redirect!
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end
end
