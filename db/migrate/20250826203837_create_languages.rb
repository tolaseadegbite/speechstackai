class CreateLanguages < ActiveRecord::Migration[8.0]
  def change
    create_table :languages do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.index :name, unique: true

      t.timestamps
    end
  end
end
