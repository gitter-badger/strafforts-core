class CreateRaceDistances < ActiveRecord::Migration[5.2]
  def change
    create_table :race_distances do |t|
      t.integer :distance
      t.string :name, index: true

      t.timestamps
    end
  end
end
