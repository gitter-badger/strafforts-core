class CreateStripeCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_customers, id: false do |t|
      t.string :id, primary_key: true
      t.references :athlete, foreign_key: true
      t.string :email

      t.timestamps
    end
  end
end
