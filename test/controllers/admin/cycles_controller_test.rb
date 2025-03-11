require "test_helper"

class Admin::CyclesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_cycles_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_cycles_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_cycles_create_url
    assert_response :success
  end
end
