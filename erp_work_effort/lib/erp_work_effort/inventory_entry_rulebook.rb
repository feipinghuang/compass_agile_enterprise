require 'ruleby'
include Ruleby

class InventoryEntryRulebook < Rulebook

  def initialize(params)
    @resource_id = params[:resource_id]
  end

  def rules
    rule [InventoryEntry, :context, m.status( &condition{ |s| } )] do
    end
  end
end

