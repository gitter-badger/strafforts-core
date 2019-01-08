class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :athlete, foreign_key: true

      t.belongs_to :subscription_plan
      t.uuid :subscription_plan_id, foreign_key: true

      t.datetime :starts_at
      t.datetime :expires_at
      t.boolean :is_active, :default => false
      t.boolean :cancel_at_period_end, :default => false
      t.boolean :is_deleted, :default => false

      t.timestamps
    end
  end
end
