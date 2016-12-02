class Reservation < ActiveRecord::Base
  has_one :reservation_request
end