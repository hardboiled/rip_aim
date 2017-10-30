class AddMessageMetadata < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :metadata, :jsonb, null: false, default: '{}'
  end
end
