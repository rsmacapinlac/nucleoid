class CreateSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :settings do |t|
      t.string :config_name
      t.string :value
      t.timestamps
    end
    add_index :settings, :config_name
  end
end
