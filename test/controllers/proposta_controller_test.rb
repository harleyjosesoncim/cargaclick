require "test_helper"

class PropostaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @propostum = proposta(:one)
  end

  test "should get index" do
    get proposta_index_url
    assert_response :success
  end

  test "should get new" do
    get new_propostum_url
    assert_response :success
  end

  test "should create propostum" do
    assert_difference("Proposta.count") do
      post proposta_index_url, params: { propostum: { frete_id: @propostum.frete_id, observacao: @propostum.observacao, transportador_id: @propostum.transportador_id, valor_proposto: @propostum.valor_proposto } }
    end

    assert_redirected_to propostum_url(Proposta.last)
  end

  test "should show propostum" do
    get propostum_url(@propostum)
    assert_response :success
  end

  test "should get edit" do
    get edit_propostum_url(@propostum)
    assert_response :success
  end

  test "should update propostum" do
    patch propostum_url(@propostum), params: { propostum: { frete_id: @propostum.frete_id, observacao: @propostum.observacao, transportador_id: @propostum.transportador_id, valor_proposto: @propostum.valor_proposto } }
    assert_redirected_to propostum_url(@propostum)
  end

  test "should destroy propostum" do
    assert_difference("Proposta.count", -1) do
      delete propostum_url(@propostum)
    end

    assert_redirected_to proposta_index_url
  end
end
