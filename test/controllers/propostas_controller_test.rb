require "test_helper"

class PropostasControllerTest < ActionDispatch::IntegrationTest
  test "should get nova" do
    get propostas_nova_url
    assert_response :success
  end

  test "should get create" do
    get propostas_create_url
    assert_response :success
  end
end
