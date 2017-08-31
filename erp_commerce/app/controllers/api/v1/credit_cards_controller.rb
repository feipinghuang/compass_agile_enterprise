module API
  module V1
    class CreditCardsController < BaseController

=begin

  @api {get} /api/v1/credit_cards Index
  @apiVersion 1.0.0
  @apiName GetCreditCards
  @apiGroup CreditCard

  @apiParam (query) {Integer} party_id Id of party to get CreditCards for
  
  @apiSuccess (200) {Object} get_credit_cards_response Response
  @apiSuccess (200) {Boolean} get_credit_cards_response.success True if the request was successful
  @apiSuccess (200) {Object[]} get_credit_cards_response.credit_cards CreditCard records
  @apiSuccess (200) {Number} get_credit_cards_response.credit_cards.id Id of CreditCard

=end

      def index
        if params[:party_id]
          credit_cards = Party.find(params[:party_id]).credit_cards
        else
          raise "party_id must be passed"
        end

        render :json => {success: true, credit_cards: credit_cards.collect(&:to_data_hash)}
      end
=begin

  @api {get} /api/v1/credit_cards Create
  @apiVersion 1.0.0
  @apiName CreateCreditCard
  @apiGroup CreditCard

  @apiParam (body) {String} description Description for Credit Card
  @apiParam (body) {String} name_on_card Name on Credit Card
  @apiParam (body) {Integer} exp_month Expiration Month for Credit Card
  @apiParam (body) {Integer} exp_year Expiration Year for Credit Card
  @apiParam (body) {String} credit_card_number Number of credit card, if using a token this would be the last 4
  @apiParam (body) {String} token Token for Credit Card

  @apiSuccess (200) {Object} create_credit_cards_response Response
  @apiSuccess (200) {Boolean} create_credit_cards_response.success True if the request was successful
  @apiSuccess (200) {Object} create_credit_cards_response.credit_card newly created CreditCard record

=end

      def create
        begin
          ActiveRecord::Base.connection.transaction do
            if params[:party_id]
              party = Party.find(params[:party_id])

              stripe_external_system = ExternalSystem.with_party_role(party.dba_organization,
                                                                      RoleType.iid('owner')).where(internal_identifier: 'stripe').first

              raise "Stripe External System is not setup" if stripe_external_system.nil?

              # we need to store the new card and then charge it
              result = CreditCard.validate_and_update({
                                                        party: party,
                                                        description: params[:description],
                                                        card_number: params[:credit_card_number],
                                                        token: params[:token],
                                                        cvc: params[:cvc],
                                                        name_on_card: params[:name_on_card],
                                                        exp_month: params[:exp_month],
                                                        exp_year: params[:exp_year]
                                                      },
                                                      party.primary_credit_card,
                                                      [stripe_external_system])

              # if adding the card was successful then retrieve it
              # if not leave it nil and the message will be returned
              if result[:success]
                credit_card = result[:credit_card]
                # manually save credit card to stripe because we need to use it to purchase
                # and we can not wait for the sync
                credit_card_handler = MasterDataManagement::ExternalSystems::EventHandlers::Stripe::CreditCard.new(credit_card.mdm_entity, stripe_external_system)
                if credit_card_handler.create(credit_card, {}) === false
                  credit_card.notify_except(stripe_external_system)
                  credit_card.destroy
                  credit_card = nil
                  result[:message] = credit_card_handler.errors.join(',')
                end

                render :json => {success: true, credit_card: credit_card.to_data_hash}
              else
                raise result[:message]
              end

            else
              raise "party_id must be passed"
            end
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not create credit card'}
        end
      end

    end # CreditCardsController
  end # V1
end # API
