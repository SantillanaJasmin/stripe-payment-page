class OnlinePaymentsController < ApplicationController
  before_action :find_payment_link, only: [:show, :confirm]

  def show
    @line_items = @payment_link.line_items

    if @payment_link.paid?
      @succeeded = true

      respond_to do |format|
        format.turbo_stream { render :confirm }
        format.html
      end
  
      return
    end

    if @payment_link.payment_intent_id.present?
      payment_intent = Stripe::PaymentIntent.retrieve(@payment_link.payment_intent_id)
    else
      payment_intent = Stripe::PaymentIntent.create(
        amount: (@payment_link.total_amount_paid * 100).to_i,
        currency: "aud",
        automatic_payment_methods: { allow_redirects: 'never', enabled: true }
      )
      @payment_link.update!(payment_intent_id: payment_intent.id)
    end

    @client_secret = payment_intent.client_secret
    @publishable_key = Settings.stripe.publishable_key
  rescue ActiveRecord::RecordNotFound
    render plain: "Payment link not found", status: :not_found
  end

  def confirm
    # Update total amount to include surcharge before confirming payment intent
    total_amount = confirm_params[:total_amount].to_f

    Stripe::PaymentIntent.update(
      @payment_link.payment_intent_id,
      { amount: (total_amount * 100).to_i }
    )

    # confirm the payment intent with the selected payment method
    payment_intent = Stripe::PaymentIntent.confirm(
      @payment_link.payment_intent_id,
      { payment_method: confirm_params[:payment_method_id] }
    )

    @succeeded = payment_intent.status == "succeeded"
    if @succeeded
      @payment_link.update!(
        status:            :paid,
        surcharge:         confirm_params[:surcharge],
        total_amount_paid: confirm_params[:total_amount]
      )
    end

    respond_to do |format|
      format.turbo_stream { render :confirm }
      format.html { redirect_to online_payment_path(@payment_link.token) }
    end
  rescue ActiveRecord::RecordNotFound
    render plain: "Payment link not found", status: :not_found
  end

  private

  def find_payment_link
    @payment_link = PaymentLink.find_by!(token: params[:token])
  end

  def confirm_params
    params.require(:payment_link).permit(:payment_method_id, :surcharge, :total_amount)
  end
end
