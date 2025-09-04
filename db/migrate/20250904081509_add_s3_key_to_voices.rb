class AddS3KeyToVoices < ActiveRecord::Migration[8.0]
  def change
    add_column :voices, :s3_key, :string
  end
end
