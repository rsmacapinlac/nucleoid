class CreateSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :sessions do |t|
      t.string  :phone_number
      t.string  :phone_number_sid
      t.string  :from_number
      t.timestamps
    end
  end
end
