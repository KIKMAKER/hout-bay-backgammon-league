require "application_system_test_case"

class MatchesTest < ApplicationSystemTestCase
  setup do
    @match = matches(:one)
  end

  test "visiting the index" do
    visit matches_url
    assert_selector "h1", text: "Matches"
  end

  test "should create match" do
    visit matches_url
    click_on "New match"

    fill_in "Cycle", with: @match.cycle_id
    fill_in "Match date", with: @match.match_date
    fill_in "Player1", with: @match.player1_id
    fill_in "Player1 score", with: @match.player1_score
    fill_in "Player2", with: @match.player2_id
    fill_in "Player2 score", with: @match.player2_score
    fill_in "Winner", with: @match.winner_id
    click_on "Create Match"

    assert_text "Match was successfully created"
    click_on "Back"
  end

  test "should update Match" do
    visit match_url(@match)
    click_on "Edit this match", match: :first

    fill_in "Cycle", with: @match.cycle_id
    fill_in "Match date", with: @match.match_date
    fill_in "Player1", with: @match.player1_id
    fill_in "Player1 score", with: @match.player1_score
    fill_in "Player2", with: @match.player2_id
    fill_in "Player2 score", with: @match.player2_score
    fill_in "Winner", with: @match.winner_id
    click_on "Update Match"

    assert_text "Match was successfully updated"
    click_on "Back"
  end

  test "should destroy Match" do
    visit match_url(@match)
    click_on "Destroy this match", match: :first

    assert_text "Match was successfully destroyed"
  end
end
