class CreateHeartRateZones < ActiveRecord::Migration[5.2]
  def change
    create_table :heart_rate_zones do |t|
      t.references :athlete, foreign_key: true

      t.boolean :custom_zones
      t.integer :zone_1_min
      t.integer :zone_1_max
      t.integer :zone_2_min
      t.integer :zone_2_max
      t.integer :zone_3_min
      t.integer :zone_3_max
      t.integer :zone_4_min
      t.integer :zone_4_max
      t.integer :zone_5_min
      t.integer :zone_5_max

      t.timestamps
    end
  end
end
