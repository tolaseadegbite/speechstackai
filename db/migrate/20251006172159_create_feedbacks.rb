class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.text :comment
      t.integer :rating
      t.integer :feedback_type
      t.integer :service
      t.references :user, null: false, foreign_key: true
      t.references :generated_audio_clip, null: true, foreign_key: true

      t.timestamps
    end
  end
end
