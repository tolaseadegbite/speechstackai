class CreateGeneratedAudioClips < ActiveRecord::Migration[8.0]
  def change
    create_table :generated_audio_clips do |t|
      t.references :user, null: false, foreign_key: true
      t.string :text
      t.string :voice
      t.string :original_voice_s3_key
      t.string :s3_key
      t.string :service
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
