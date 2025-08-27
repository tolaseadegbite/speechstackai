class CreateLanguageVoices < ActiveRecord::Migration[8.0]
  def change
    create_table :language_voices do |t|
      t.references :language, null: false, foreign_key: true
      t.references :voice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
