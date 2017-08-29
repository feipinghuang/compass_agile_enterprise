module API
  module V1
    class BankAccountsController < BaseController

=begin

  @api {get} /api/v1/bank_accounts Index
  @apiVersion 1.0.0
  @apiName GetBankAccounts
  @apiGroup BankAccount

  @apiParam (query) {Integer} party_id Id of party to get BankAccounts for
  
  @apiSuccess (200) {Object} get_bank_accounts_response Response
  @apiSuccess (200) {Boolean} get_bank_accounts_response.success True if the request was successful
  @apiSuccess (200) {Object[]} get_bank_accounts_response.bank_accounts BankAccount records
  @apiSuccess (200) {Number} get_bank_accounts_response.bank_accounts.id Id of BankAccount

=end

      def index
        if params[:party_id]
          bank_accounts = Party.find(params[:party_id]).bank_accounts

          render :json => {success: true, bank_accounts: bank_accounts.collect(&:to_data_hash)}
        else
          render :json => {success: false, message: "party_id must be passed"}
        end
      end

=begin

  @api {get} /api/v1/bank_accounts Create
  @apiVersion 1.0.0
  @apiName CreateBankAccount
  @apiGroup BankAccount

  @apiParam (body) {Integer} party_id Id of party to relate to this BankAccount
  @apiParam (body) {String} description Description for BankAccount
  @apiParam (body) {String} [bank_token] Token for BankAccount
  @apiParam (body) {String} [account_number] Account number for BankAccount
  @apiParam (body) {String} [routing_number] Routing number for BankAccount
  @apiParam (body) {String} [account_holder_name] Account holder name for BankAccount
  @apiParam (body) {String} [account_holder_type] Account holder type for BankAccount (individual | business)
  @apiParam (body) {String} [bank_account_type] Account type for BankAccount (checking | savings)

  @apiSuccess (200) {Object} create_bank_accounts_response Response
  @apiSuccess (200) {Boolean} create_bank_accounts_response.success True if the request was successful
  @apiSuccess (200) {Object} create_bank_accounts_response.bank_account newly created BankAccount record

=end

      def create
        if params[:party_id]
          begin
            ActiveRecord::Base.connection.transaction do
              bank_account = BankAccount.new
              bank_account.description = params[:description]
              bank_account.bank_token = params[:bank_token]
              bank_account.account_number = params[:account_number]
              bank_account.routing_number = params[:routing_number]
              bank_account.name_on_account = params[:name_on_account]
              bank_account.account_holder_type = params[:account_holder_type]

              if params[:bank_account_type]
                bank_account.bank_account_type = BankAccoutType.find_or_create(params[:bank_account_type], params[:bank_account_type].humanize)
              end

              bank_account.save!

              bank_account.account_root.add_party_with_role(Party.find(params[:party_id]), 'owner')

              render :json => {success: true, bank_account: bank_account.to_data_hash}
            end
          rescue ActiveRecord::RecordInvalid => invalid
            Rails.logger.error invalid.record.errors

            render :json => {:success => false, :message => invalid.record.errors}
          rescue StandardError => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            render json: {success: false, message: 'Error creating bank account'}
          end
        else
          render :json => {success: false, message: "party_id must be passed"}
        end
      end

    end # BankAccountsController
  end # V1
end # API
