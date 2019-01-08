class CreateRaces < ActiveRecord::Migration[5.2]
  def change
    create_table :races do |t|
      t.references :activity, foreign_key: true
      t.references :athlete, foreign_key: true
      t.references :race_distance, foreign_key: true

      t.timestamps
    end
  end
end
