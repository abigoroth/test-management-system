class CreateResults < ActiveRecord::Migration[6.0]
  def change
    create_table :results do |t|
      t.string :expected
      t.string :actual
      t.boolean :pass
      t.integer :spec_id

      t.timestamps
    end
  end
end
