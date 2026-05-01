require "securerandom"

module Payments
  class FakeGateway
    GatewayResponse = Struct.new(:success?, :transaction_id, :error, keyword_init: true)

    # Stubbed in-app gateway for demo purposes:
    # token "fail" simulates declined payment, anything else succeeds.
    def capture(amount_cents:, source_token:)
      return GatewayResponse.new(success?: false, transaction_id: nil, error: "Card declined") if source_token == "fail"

      transaction_id = "tx_#{SecureRandom.hex(6)}"
      GatewayResponse.new(success?: true, transaction_id: transaction_id, error: nil)
    end
  end
end
