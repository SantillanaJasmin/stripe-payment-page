class CreatePaymentLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_links do |t|
      t.string :status
      t.jsonb :line_items
      t.string :token

      t.timestamps
    end

    add_index :payment_links, :token, unique: true
  end
end
