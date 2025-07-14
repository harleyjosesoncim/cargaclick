require "test_helper"

class CotacaosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cotacao = cotacaos(:one)
  end

  test "should get index" do
    get cotacaos_url
    assert_response :success
  end

  test "should get new" do
    get new_cotacao_url
    assert_response :success
  end

  test "should create cotacao" do
    assert_difference("Cotacao.count") do
      post cotacaos_url, params: { cotacao: { cliente_id: @cotacao.cliente_id, destino: @cotacao.destino, origem: @cotacao.origem, peso: @cotacao.peso, status: @cotacao.status, volume: @cotacao.volume } }
    end

    assert_redirected_to cotacao_url(Cotacao.last)
  end

  test "should show cotacao" do
    get cotacao_url(@cotacao)
    assert_response :success
  end

  test "should get edit" do
    get edit_cotacao_url(@cotacao)
    assert_response :success
  end

  test "should update cotacao" do
    patch cotacao_url(@cotacao), params: { cotacao: { cliente_id: @cotacao.cliente_id, destino: @cotacao.destino, origem: @cotacao.origem, peso: @cotacao.peso, status: @cotacao.status, volume: @cotacao.volume } }
    assert_redirected_to cotacao_url(@cotacao)
  end

  test "should destroy cotacao" do
    assert_difference("Cotacao.count", -1) do
      delete cotacao_url(@cotacao)
    end

    assert_redirected_to cotacaos_url
  end
end
