class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.string :content
      t.integer :message_type
      t.references :sender, type: :uuid, foreign_key: { to_table: :users }, index: true
      t.references :recipient, type: :uuid, foreign_key: { to_table: :users }, index: true

      t.timestamps
    end
  end
end
