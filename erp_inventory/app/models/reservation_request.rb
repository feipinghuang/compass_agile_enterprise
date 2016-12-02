class ReservationRequest < ActiveRecord::Base
  has_one :reservation

  def valid?
  end

  def accept
  end

  def reject
  end
end