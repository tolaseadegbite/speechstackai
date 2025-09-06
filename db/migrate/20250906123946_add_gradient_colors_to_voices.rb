class AddGradientColorsToVoices < ActiveRecord::Migration[8.0]
  def change
    add_column :voices, :gradient_start, :string
    add_column :voices, :gradient_end, :string
  end
end
