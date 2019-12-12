class CreateSpecs < ActiveRecord::Migration[6.0]
  def change
    create_table :specs do |t|
      t.string :name
      t.text :step
      t.integer :feature_id
      t.string :expected
      t.text :description

      t.timestamps
    end
  end
end
