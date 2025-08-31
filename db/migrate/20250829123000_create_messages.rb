class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :frete, null: false, foreign_key: true
      t.string :sender_type, null: false
      t.bigint :sender_id, null: false
      t.text :content, null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end unless table_exists?(:messages)
  end
end
