class AddIndexToGeneratedAudioClipsOnUserAndCreatedAt < ActiveRecord::Migration[8.0]
  def change
    add_index :generated_audio_clips, [:user_id, :created_at]
  end
end
