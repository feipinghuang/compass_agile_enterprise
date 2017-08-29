module API
  module V1
    class InventoryTxnsController < BaseController

=begin

  @api {put} /api/v1/inventory_txns/:id/apply 
  @apiVersion 1.0.0
  @apiName ApplyInventoryTxn
  @apiGroup InventoryTxn
  @apiDescription Apply an InventoryTxn

  @apiParam (query) {Integer} id InventoryTxn Id
  
  @apiSuccess (200) {Object} apply_inventory_txn_response Response
  @apiSuccess (200) {Boolean} apply_inventory_txn_response.success True if the request was successful

=end

      def apply
        begin
          ActiveRecord::Base.transaction do
            inventory_txn = InventoryTxn.find(params[:id])

            inventory_txn.apply!

            render :json => {success: true}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not apply'}
        end
      end

=begin

  @api {put} /api/v1/inventory_txns/:id/unapply 
  @apiVersion 1.0.0
  @apiName UnapplyInventoryTxn
  @apiGroup InventoryTxn
  @apiDescription Unapply an InventoryTxn

  @apiParam (query) {Integer} id InventoryTxn Id
  
  @apiSuccess (200) {Object} unapply_inventory_txn_response Response
  @apiSuccess (200) {Boolean} unapply_inventory_txn_response.success True if the request was successful

=end

      def unapply
        begin
          ActiveRecord::Base.transaction do
            inventory_txn = InventoryTxn.find(params[:id])

            inventory_txn.unapply!

            render :json => {success: true}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not unapply'}
        end
      end

    end # InventoryTxnsController
  end # V1
end # API
