require "test_helper"

class BolsaoControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get bolsao_index_url
    assert_response :success
  end
end
