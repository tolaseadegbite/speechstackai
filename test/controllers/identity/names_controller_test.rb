require "test_helper"

class Identity::NamesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get identity_names_edit_url
    assert_response :success
  end

  test "should get update" do
    get identity_names_update_url
    assert_response :success
  end
end
