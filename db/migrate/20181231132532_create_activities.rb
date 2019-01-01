class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities, id: false do |t|
      t.bigint :id, primary_key: true

      t.references :athlete, foreign_key: true
      t.references :workout_type, foreign_key: true

      t.string :name
      t.string :description
      t.float :distance
      t.integer :moving_time
      t.integer :elapsed_time
      t.float :total_elevation_gain
      t.float :elev_high
      t.float :elev_low
      t.datetime :start_date
      t.datetime :start_date_local
      t.string :timezone
      t.integer :athlete_count
      t.boolean :trainer
      t.boolean :commute
      t.boolean :manual
      t.boolean :private
      t.string :device_name
      t.boolean :flagged
      t.float :average_speed
      t.float :max_speed
      t.float :average_cadence
      t.float :average_temp
      t.boolean :has_heartrate
      t.float :average_heartrate
      t.integer :max_heartrate
      t.float :calories
      t.integer :suffer_score

      t.belongs_to :gear
      t.string :gear_id

      t.timestamps
    end
  end
end
