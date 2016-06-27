module Api
  module V1
    class CreditCardsController < BaseController

=begin

  @api {get} /api/v1/credit_cards Index
  @apiVersion 1.0.0
  @apiName GetCreditCards
  @apiGroup CreditCard

  @apiSuccess {Boolean} success True if the request was successful
  @apiSuccess {Array} credit_cards GetCreditCard records

=end

      def index
        if params[:party_id]
          credit_cards = Party.find(params[:party_id]).credit_cards
        else
          raise "party_id must be passed"
        end

        render :json => {success: true, credit_cards: credit_cards.collect(&:to_data_hash)}
      end

    end # CreditCardsController
  end # V1
end # Api
