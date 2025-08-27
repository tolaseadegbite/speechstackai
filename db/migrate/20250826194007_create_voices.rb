class CreateVoices < ActiveRecord::Migration[8.0]
  def change
    create_table :voices do |t|
      t.string :name, null: false
      # t.string :language, null: false
      t.string :gender, null: false
      t.string :description
      # t.references :generated_audio_clip, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
