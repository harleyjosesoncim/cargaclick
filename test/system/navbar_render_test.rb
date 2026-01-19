require "application_system_test_case"

class NavbarRenderTest < ApplicationSystemTestCase

  test "homepage renderiza navbar sem erro" do
    visit root_path
    assert_selector "nav", text: "CargaClick"
  end

end
