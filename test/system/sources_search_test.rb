require "application_system_test_case"

class SourcesSearchTest < ApplicationSystemTestCase
  setup do
    sign_in_as(users(:admin))

    @source1 = Sources::Oai.create!(name: "Archive Collection", url: "https://demo.archivesspace.org/oai")
    @source2 = Sources::Oai.create!(name: "Digital Repository", url: "https://sandbox.archivesspace.org/oai")
    @source3 = Sources::Oai.create!(name: "Special Collection", url: "https://test.archivesspace.org/oai")
  end

  test "searching for sources" do
    visit sources_path

    assert_selector "h2", text: "Sources"
    assert_text @source1.name
    assert_text @source2.name
    assert_text @source3.name

    fill_in "query", with: "Archive"
    click_button "Search"

    assert_text @source1.name
    assert_no_text @source2.name
    assert_text @source3.name, count: 0

    assert_current_path sources_path(query: "Archive")

    click_link "Reset"

    assert_text @source1.name
    assert_text @source2.name
    assert_text @source3.name
    assert_current_path sources_path
  end

  test "searching with no results" do
    visit sources_path

    fill_in "query", with: "NonExistentSource"
    click_button "Search"

    assert_no_text @source1.name
    assert_no_text @source2.name
    assert_no_text @source3.name
  end
end
