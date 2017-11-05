class FixUsernameIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :username
    add_index :users, 'username varchar_pattern_ops'
  end
end
