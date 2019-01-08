class CreateWorkoutTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :workout_types do |t|
      t.string :name, index: true

      t.timestamps
    end
  end
end
