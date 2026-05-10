FactoryBot.define do
  factory :payment_link do
    status { "active" }
    line_items do
      [
        { "name" => "Widget", "quantity" => 2, "amount" => 50 },
        { "name" => "Gadget", "quantity" => 1, "amount" => 25 }
      ]
    end

    trait :with_payment_intent do
      payment_intent_id { "pi_existing_intent" }
    end

    trait :paid do
      status { "paid" }
      payment_intent_id { "pi_paid_intent" }
    end
  end
end
