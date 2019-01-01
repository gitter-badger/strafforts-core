class CreateFaqs < ActiveRecord::Migration[5.2]
  def change
    create_table :faqs do |t|
      t.references :faq_category, foreign_key: true

      t.text :title
      t.text :content

      t.timestamps
    end
  end
end
