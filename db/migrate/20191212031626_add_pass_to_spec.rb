class AddPassToSpec < ActiveRecord::Migration[6.0]
  def change
    add_column :specs, :pass, :boolean, default: false
  end
end
