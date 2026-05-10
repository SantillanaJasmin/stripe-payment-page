class PaymentLink < ApplicationRecord
  STATUSES = %w[active paid expired].freeze

  before_create :set_total_amount_paid
  before_validation :generate_token, on: :create

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :line_items, presence: true
  validates :token, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9\-_]+\z/ }

  def line_items_total
    line_items.sum { |item| item["amount"].to_i * item["quantity"].to_i }
  end

  def paid?
    status == "paid"
  end

  private

  def set_total_amount_paid
    self.total_amount_paid = line_items_total
  end

  def generate_token
    loop do
      self.token = SecureRandom.urlsafe_base64(30)
      break unless PaymentLink.exists?(token: token) || token.include?("-") || token.include?("_")
    end
  end
end
