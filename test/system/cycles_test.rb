require "application_system_test_case"

class CyclesTest < ApplicationSystemTestCase
  setup do
    @cycle = cycles(:one)
  end

  test "visiting the index" do
    visit cycles_url
    assert_selector "h1", text: "Cycles"
  end

  test "should create cycle" do
    visit cycles_url
    click_on "New cycle"

    fill_in "End date", with: @cycle.end_date
    fill_in "Group", with: @cycle.group_id
    fill_in "Start date", with: @cycle.start_date
    fill_in "Weeks", with: @cycle.weeks
    click_on "Create Cycle"

    assert_text "Cycle was successfully created"
    click_on "Back"
  end

  test "should update Cycle" do
    visit cycle_url(@cycle)
    click_on "Edit this cycle", match: :first

    fill_in "End date", with: @cycle.end_date
    fill_in "Group", with: @cycle.group_id
    fill_in "Start date", with: @cycle.start_date
    fill_in "Weeks", with: @cycle.weeks
    click_on "Update Cycle"

    assert_text "Cycle was successfully updated"
    click_on "Back"
  end

  test "should destroy Cycle" do
    visit cycle_url(@cycle)
    click_on "Destroy this cycle", match: :first

    assert_text "Cycle was successfully destroyed"
  end
end
