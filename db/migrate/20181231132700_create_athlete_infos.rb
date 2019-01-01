class CreateAthleteInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :athlete_infos, id: false do |t|
      t.references :athlete, foreign_key: true, primary_key: true

      t.string :username, index: true
      t.string :firstname
      t.string :lastname

      t.string :profile_medium
      t.string :profile

      t.references :city, foreign_key: true
      t.references :state, foreign_key: true
      t.references :country, foreign_key: true

      t.string :sex
      t.integer :follower_count
      t.integer :friend_count
      t.integer :athlete_type
      t.string :date_preference
      t.string :measurement_preference
      t.float :weight

      t.timestamps
    end
  end
end
