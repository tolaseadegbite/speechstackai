class ChangeServiceColumnTypeInGeneratedAudioClips < ActiveRecord::Migration[8.0]
  def up
    # The USING clause tells PostgreSQL how to cast the existing string values (like "0") to integers.
    change_column :generated_audio_clips, :service, 'integer USING CAST(service AS integer)'
    
    # It's a good practice to set a default value for enum columns.
    # We'll set it to 0, which corresponds to :text_to_speech.
    change_column_default :generated_audio_clips, :service, 0
  end

  def down
    # Revert the changes if we ever need to rollback.
    change_column_default :generated_audio_clips, :service, nil
    change_column :generated_audio_clips, :service, :string
  end
end
