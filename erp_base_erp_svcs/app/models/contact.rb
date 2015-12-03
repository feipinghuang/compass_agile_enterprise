class Contact < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_and_belongs_to_many :contact_purposes
  belongs_to :contact_mechanism, :polymorphic => true, :dependent => :destroy
  belongs_to :contact_record, :polymorphic => true

  #rather than carry our own description for the abstract -contact-, we'll
  #delegate that call to the implementer of the -contact_mechanism- interface

  def description
    @description = contact_mechanism.description
  end

  def description=(d)
    @description=d
  end

  def party
    if self.contact_record_type == 'Party'
      self.contact_record
    else
      nil
    end
  end

  def party=(party)
    self.contact_record = party
  end

  #delegate our need to provide a label to scaffolds to the implementer of
  #the -contact_mechanism- interface.

  def to_label
    "#{contact_mechanism.description}"
  end

  def summary_line
    "#{contact_mechanism.summary_line}"
  end

  def is_primary?
    self.is_primary
  end

  # return first contact purpose
  def purpose
    contact_purposes.first.description
  end

  # return all contact purposes as an array
  def purposes
    p = []
    contact_purposes.each do |cp|
      p << cp.description
    end

    return p
  end
end
