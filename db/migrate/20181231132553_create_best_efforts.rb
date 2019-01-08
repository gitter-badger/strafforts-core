class CreateBestEfforts < ActiveRecord::Migration[5.2]
  def change
    create_table :best_efforts, id: false do |t|
      t.bigint :id, primary_key: true

      t.references :activity, foreign_key: true
      t.references :athlete, foreign_key: true
      t.references :best_effort_type, foreign_key: true

      t.integer :pr_rank
      t.float :distance
      t.integer :moving_time
      t.integer :elapsed_time
      t.datetime :start_date
      t.datetime :start_date_local

      t.timestamps
    end
  end
end
