class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[ show edit update destroy ]

  # GET /payments or /payments.json
  def index
    @payments = Payments::IndexQuery.call(params: index_query_params)
  end

  # GET /payments/1 or /payments/1.json
  def show
  end

  # GET /payments/new
  def new
    @form = Payments::CapturePaymentForm.new
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments or /payments.json
  def create
    @form = Payments::CapturePaymentForm.new

    respond_to do |format|
      if @form.submit(capture_payment_params)
        @payment = @form.payment
        format.html { redirect_to @payment, notice: "Payment was captured successfully." }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment, notice: "Payment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1 or /payments/1.json
  def destroy
    @payment.destroy!

    respond_to do |format|
      format.html { redirect_to payments_path, notice: "Payment was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.expect(payment: [ :order_id, :provider, :status, :amount_cents, :transaction_id, :paid_at ])
    end

    def capture_payment_params
      params.expect(capture_payment: [ :order_id, :source_token, :provider ])
    end

    def index_query_params
      params.permit(:status, :provider, :order_id, :paid_from, :paid_to, :sort).to_h.symbolize_keys
    end
end
