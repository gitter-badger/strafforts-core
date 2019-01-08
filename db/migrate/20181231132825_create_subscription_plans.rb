class CreateSubscriptionPlans < ActiveRecord::Migration[5.2]
  def change
    enable_extension "uuid-ossp"
    enable_extension "pgcrypto"

    create_table :subscription_plans, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name
      t.string :description
      t.integer :duration # length of the subscription plan in days.
      t.float :amount
      t.float :amount_per_month

      t.timestamps
    end
  end
end
