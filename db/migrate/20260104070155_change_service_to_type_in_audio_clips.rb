class ChangeServiceToTypeInAudioClips < ActiveRecord::Migration[8.0]
  def up
    # Add the type column for STI
    add_column :generated_audio_clips, :type, :string

    # Migrate existing data (mapping your enum to class names)
    GeneratedAudioClip.where(service: 0).update_all(type: 'TextToSpeechClip')
    GeneratedAudioClip.where(service: 1).update_all(type: 'VoiceConversionClip')

    # Remove the old column
    remove_column :generated_audio_clips, :service
  end
end
