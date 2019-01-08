class CreateAthletes < ActiveRecord::Migration[5.2]
  def change
    create_table :athletes, id: false do |t|
      t.bigint :id, primary_key: true

      t.string :access_token, index: true
      t.string :email
      t.boolean :is_public, default: true
      t.boolean :is_active, default: true

      t.integer :total_run_count, default: 0
      t.integer :last_activity_retrieved
      t.datetime :last_active_at

      t.string :refresh_token
      t.datetime :refresh_token_expires_at

      t.boolean :email_confirmed, default: false
      t.string :confirmation_token, unique: true, index: true
      t.datetime :confirmation_sent_at
      t.datetime :confirmed_at

      t.timestamps
    end
  end
end
