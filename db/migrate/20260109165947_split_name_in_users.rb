class SplitNameInUsers < ActiveRecord::Migration[8.0]
  def up
    # 1. Add new columns
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    # 2. Migrate existing data
    # We use 'update_columns' to skip validations during migration
    User.find_each do |user|
      next if user.name.blank?

      names = user.name.strip.split(/\s+/, 2) # Split into max 2 parts
      first = names[0]
      last = names[1] || "" # Handle cases with single names

      user.update_columns(first_name: first, last_name: last)
    end

    # 3. Remove the old column and its index
    remove_column :users, :name
  end

  def down
    add_column :users, :name, :string
    add_index :users, :name, unique: true

    User.find_each do |user|
      full_name = "#{user.first_name} #{user.last_name}".strip
      user.update_columns(name: full_name)
    end

    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
