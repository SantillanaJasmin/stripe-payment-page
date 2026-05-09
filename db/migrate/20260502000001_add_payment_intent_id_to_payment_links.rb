class AddPaymentIntentIdToPaymentLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :payment_links, :payment_intent_id, :string
  end
end
