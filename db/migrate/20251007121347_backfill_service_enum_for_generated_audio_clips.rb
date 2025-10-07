class BackfillServiceEnumForGeneratedAudioClips < ActiveRecord::Migration[8.0]
  # Define a temporary local model to prevent conflicts with application code
  class GeneratedAudioClip < ApplicationRecord
    self.table_name = 'generated_audio_clips'
  end

  def up
    say_with_time "Updating 'african-tts' service strings to enum integer '0'" do
      # Use update_all for a single, efficient SQL query.
      # This finds all clips where service is 'african-tts' and sets it to '0'
      GeneratedAudioClip.where(service: "african-tts").update_all(service: "0")
    end
  end

  def down
    say_with_time "Reverting service enum integer '0' back to 'african-tts' string" do
      # This makes the migration reversible.
      GeneratedAudioClip.where(service: "0").update_all(service: "african-tts")
    end
  end
end
