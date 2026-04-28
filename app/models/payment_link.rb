class PaymentLink < ApplicationRecord
  STATUSES = %w[active inactive expired].freeze

  before_create :generate_token

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :line_items, presence: true
  validates :token, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9\-_]+\z/ }

  private

  def generate_token
    loop do
      self.token = SecureRandom.urlsafe_base64(30)
      break unless PaymentLink.exists?(token: token)
    end
  end
end
