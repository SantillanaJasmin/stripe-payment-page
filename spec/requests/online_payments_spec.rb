require "rails_helper"

RSpec.describe "OnlinePayments", type: :request do
  let(:line_items) do
    [
      { "name" => "Widget", "quantity" => 2, "amount" => 50 },
      { "name" => "Gadget", "quantity" => 1, "amount" => 25 }
    ]
  end

  let(:payment_intent_double) do
    double("Stripe::PaymentIntent",
      id:            "pi_test_123456",
      client_secret: "pi_test_123456_secret_abc")
  end

  let(:turbo_stream_headers) do
    { "Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }
  end

  describe "GET /pay/:token" do
    context "when the payment link does not exist" do
      it "returns 404" do
        get "/pay/unknowntoken"

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the payment link is active" do
      let(:payment_link) { create(:payment_link, line_items: line_items) }

      context "with no existing payment intent" do
        before do
          allow(Stripe::PaymentIntent).to receive(:create).and_return(payment_intent_double)
        end

        it "creates a Stripe PaymentIntent with the correct amount and currency" do
          get "/pay/#{payment_link.token}"

          expect(Stripe::PaymentIntent).to have_received(:create).with(
            hash_including(
              amount:   12500,
              currency: "aud"
            )
          )
        end

        it "persists the new payment intent ID on the payment link" do
          expect {
            get "/pay/#{payment_link.token}"
          }.to change { payment_link.reload.payment_intent_id }
            .from(nil).to("pi_test_123456")
        end

        it "returns 200" do
          get "/pay/#{payment_link.token}"

          expect(response).to have_http_status(:ok)
        end
      end

      context "with an existing payment intent" do
        let(:payment_link) { create(:payment_link, :with_payment_intent, line_items: line_items) }

        before do
          allow(Stripe::PaymentIntent).to receive(:retrieve).and_return(payment_intent_double)
          allow(Stripe::PaymentIntent).to receive(:create)
        end

        it "retrieves the existing PaymentIntent without creating a new one" do
          get "/pay/#{payment_link.token}"

          expect(Stripe::PaymentIntent).to have_received(:retrieve).with("pi_existing_intent")
          expect(Stripe::PaymentIntent).not_to have_received(:create)
        end

        it "returns 200" do
          get "/pay/#{payment_link.token}"

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "when the payment link has already been paid" do
      let(:payment_link) { create(:payment_link, :paid, line_items: line_items) }

      before do
        allow(Stripe::PaymentIntent).to receive(:retrieve).and_return(payment_intent_double)
        allow(Stripe::PaymentIntent).to receive(:create)
      end

      it "does not call Stripe" do
        get "/pay/#{payment_link.token}"

        expect(Stripe::PaymentIntent).not_to have_received(:retrieve)
        expect(Stripe::PaymentIntent).not_to have_received(:create)
      end

      it "returns 200" do
        get "/pay/#{payment_link.token}"

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /pay/:token/confirm" do
    let(:payment_link) { create(:payment_link, :with_payment_intent, line_items: line_items) }
    let(:succeeded_intent) { double("Stripe::PaymentIntent", status: "succeeded") }
    let(:failed_intent)    { double("Stripe::PaymentIntent", status: "requires_payment_method") }

    let(:confirm_params) do
      {
        payment_link: {
          payment_method_id: "pm_card_visa",
          surcharge:         "2.19",
          total_amount:      "127.19"
        }
      }
    end

    context "when the payment link does not exist" do
      it "returns 404" do
        post "/pay/unknowntoken/confirm", params: confirm_params

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the payment succeeds" do
      before do
        allow(Stripe::PaymentIntent).to receive(:update)
        allow(Stripe::PaymentIntent).to receive(:confirm).and_return(succeeded_intent)
      end

      it "updates the PaymentIntent amount to include the surcharge" do
        post "/pay/#{payment_link.token}/confirm", params: confirm_params

        expect(Stripe::PaymentIntent).to have_received(:update).with(
          "pi_existing_intent",
          { amount: 12719 }
        )
      end

      it "confirms the PaymentIntent with the provided payment method" do
        post "/pay/#{payment_link.token}/confirm", params: confirm_params

        expect(Stripe::PaymentIntent).to have_received(:confirm).with(
          "pi_existing_intent",
          { payment_method: "pm_card_visa" }
        )
      end

      it "marks the payment link as paid" do
        expect {
          post "/pay/#{payment_link.token}/confirm", params: confirm_params
        }.to change { payment_link.reload.status }.from("active").to("paid")
      end

      it "saves surcharge and total amount on the payment link" do
        post "/pay/#{payment_link.token}/confirm", params: confirm_params

        payment_link.reload
        expect(payment_link.surcharge).to eq(2.19)
        expect(payment_link.total_amount_paid).to eq(127.19)
      end

      context "with turbo stream format" do
        it "renders a turbo stream response" do
          post "/pay/#{payment_link.token}/confirm",
               params:  confirm_params,
               headers: turbo_stream_headers

          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        end
      end

      context "with HTML format" do
        it "redirects to the payment page" do
          post "/pay/#{payment_link.token}/confirm", params: confirm_params

          expect(response).to redirect_to(online_payment_path(payment_link.token))
        end
      end
    end

    context "when the payment fails" do
      before do
        allow(Stripe::PaymentIntent).to receive(:update)
        allow(Stripe::PaymentIntent).to receive(:confirm).and_return(failed_intent)
      end

      it "does not mark the payment link as paid" do
        expect {
          post "/pay/#{payment_link.token}/confirm", params: confirm_params
        }.not_to change { payment_link.reload.status }
      end

      context "with turbo stream format" do
        it "renders a turbo stream response" do
          post "/pay/#{payment_link.token}/confirm",
               params:  confirm_params,
               headers: turbo_stream_headers

          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        end
      end
    end

    context "when the card is declined" do
      before do
        allow(Stripe::PaymentIntent).to receive(:update)
        allow(Stripe::PaymentIntent).to receive(:confirm)
          .with(payment_link.payment_intent_id, { payment_method: confirm_params[:payment_link][:payment_method_id] })
          .and_raise(Stripe::CardError.new("Your card was declined.", "number"))
      end

      it "does not mark the payment link as paid" do
        expect {
          post "/pay/#{payment_link.token}/confirm", params: confirm_params
        }.not_to change { payment_link.reload.status }
      end

      context "with turbo stream format" do
        it "renders an error response" do
          post "/pay/#{payment_link.token}/confirm",
               params:  confirm_params,
               headers: turbo_stream_headers

          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        end
      end
    end
  end
end
