require "test_helper"

class AutenticacaoTest < ActionDispatch::IntegrationTest

  test "tela de cadastro do cliente existe" do
    get new_cliente_registration_path
    assert_response :success
  end

  test "tela de login do cliente existe" do
    get new_cliente_session_path
    assert_response :success
  end

end
