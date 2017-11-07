class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.string :from
      t.string :to
      t.string :body
      t.timestamps
    end
    add_index :messages, :from
    add_index :messages, :to
  end
end
