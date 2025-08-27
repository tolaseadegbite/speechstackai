class RemoveVoiceFromGeneratedAudioClips < ActiveRecord::Migration[8.0]
  def change
    remove_column :generated_audio_clips, :voice, :string
  end
end
