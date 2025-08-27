require "application_system_test_case"

class VoicesTest < ApplicationSystemTestCase
  setup do
    @voice = voices(:one)
  end

  test "visiting the index" do
    visit voices_url
    assert_selector "h1", text: "Voices"
  end

  test "should create voice" do
    visit voices_url
    click_on "New voice"

    fill_in "Gender", with: @voice.gender
    fill_in "Generated audio clip", with: @voice.generated_audio_clip_id
    fill_in "Language", with: @voice.language
    fill_in "Name", with: @voice.name
    fill_in "User", with: @voice.user_id
    click_on "Create Voice"

    assert_text "Voice was successfully created"
    click_on "Back"
  end

  test "should update Voice" do
    visit voice_url(@voice)
    click_on "Edit this voice", match: :first

    fill_in "Gender", with: @voice.gender
    fill_in "Generated audio clip", with: @voice.generated_audio_clip_id
    fill_in "Language", with: @voice.language
    fill_in "Name", with: @voice.name
    fill_in "User", with: @voice.user_id
    click_on "Update Voice"

    assert_text "Voice was successfully updated"
    click_on "Back"
  end

  test "should destroy Voice" do
    visit voice_url(@voice)
    click_on "Destroy this voice", match: :first

    assert_text "Voice was successfully destroyed"
  end
end
