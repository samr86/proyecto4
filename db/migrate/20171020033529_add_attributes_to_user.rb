class AddAttributesToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :nombres, :string
    add_column :users, :apellidos, :string
  end
end
