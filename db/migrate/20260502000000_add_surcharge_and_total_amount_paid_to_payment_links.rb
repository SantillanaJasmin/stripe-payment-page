class AddSurchargeAndTotalAmountPaidToPaymentLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :payment_links, :surcharge, :decimal, precision: 10, scale: 2, default: 0, null: false
    add_column :payment_links, :total_amount_paid, :decimal, precision: 10, scale: 2
  end
end
