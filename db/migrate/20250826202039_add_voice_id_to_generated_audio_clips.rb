class AddVoiceIdToGeneratedAudioClips < ActiveRecord::Migration[8.0]
  def change
    add_reference :generated_audio_clips, :voice, foreign_key: true, null: true
  end
end
