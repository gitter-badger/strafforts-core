class CreateGears < ActiveRecord::Migration[5.2]
  def change
    create_table :gears, id: false do |t|
      t.string :gear_id, primary_key: true

      t.references :athlete, foreign_key: true

      t.string :name
      t.boolean :primary, default: false
      t.float :distance
      t.string :brand_name
      t.string :model
      t.string :description

      t.timestamps
    end
  end
end
