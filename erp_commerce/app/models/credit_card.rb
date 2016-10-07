#### Table Definition ####################################
#  create_table :credit_cards do |t|
#
#    t.column :crypted_private_card_number,       :string
#    t.column :crypted_private_cvc,               :string
#    t.column :expiration_month,                  :integer
#    t.column :expiration_year,                   :integer
#
#    t.column :description,                       :string
#    t.column :name_one_card,                     :string
#    t.column :card_type,                         :string
#
#    t.column :postal_address_id,                 :integer
#    t.column :credit_card_token,                 :string
#
#    t.timestamps
#  end
#########################################################

class CreditCard < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  belongs_to :postal_address
  has_one :credit_card_account_party_role, :dependent => :destroy

  #validates :card_type, :presence => {:message => 'Card type cannot be blank.'}
  validates :expiration_month, presence: true
  validates :expiration_year, presence: true
  validates :crypted_private_card_number, presence: true

  #the function EncryptionKey.get_key is meant to be overridden to provide a means for implementations to specify their
  #own encryption schemes and locations. It will default to a simple string for development and testing
  attr_encrypted :private_card_number, :key => Rails.application.config.erp_commerce.encryption_key, :attribute => :crypted_private_card_number
  attr_encrypted :private_cvc, :key => Rails.application.config.erp_commerce.encryption_key, :attribute => :crypted_private_cvc

  class << self
    def mask_number(number)
      'XXXX-XXXX-XXXX-' + number[number.length-4..number.length]
    end
  end

  # These methods are exposed for the purposes of displaying a version of the card number
  # string containing the last four digits of the card number. The idea is to make it
  # painfully obvious when any coder is using the private_card_number, which should
  # be used only in limited circumstances.

  #these two methods allow us to assign instance level attributes that are not persisted.  These are used for validators
  def instance_attributes
    @instance_attrs.nil? ? {} : @instance_attrs
  end

  def add_instance_attribute(k, v)
    @instance_attrs = {} if @instance_attrs.nil?
    @instance_attrs[k] = v
  end

  def card_number
    if self.private_card_number
      CreditCard.mask_number(self.private_card_number)
    else
      ''
    end
  end

  def last_4
    card_number[card_number.length-4..card_number.length]
  end

  def expires
    "#{expiration_month}/#{expiration_year}"
  end

  def cvc=(cvc)
    self.private_cvc=cvc
  end

  def card_number=(num)
    self.private_card_number=num
  end

  def to_label
    "#{card_type}: #{card_number}"
  end

  def to_s
    "#{card_type}: #{card_number}"
  end

  def cardholder
    if self.credit_card_account_party_role
      self.credit_card_account_party_role.party
    end
  end

  def before_create
    token = CreditCardToken.new
    self.credit_card_token = token.cc_token.strip
  end

  def to_data_hash
    to_hash(only: [:description, :id, :expiration_month, :expiration_year], methods: [:last_4])
  end

end
