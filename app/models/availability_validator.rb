require 'date'

class AvailabilityValidator < ServiceValidator
  include ActiveModel::Validations
  
  attr_accessor :arrival_date
  attr_accessor :num_nights
  attr_accessor :internal_UID
  attr_accessor :type_ID
  attr_accessor :unit_length
  attr_accessor :request_unav
  
  validates :arrival_date, format: { with: /\A^[0-9\-]*\z/, message: "Arrival Date can only be numbers and dashes."}
  validates :arrival_date, format: { with: /\A....\-..\-..\z/, message: "Arrival Date must be in the format of YYYY-MM-DD."}
  validates :num_nights, format: { with: /\A^[0-9]*[1-9]\z/, message: "Number of Nights must be a number which is greater than 0."}
  
  validate  :valid_date
  
  def initialize(form)
    @request_ID = "SiteAvailabilityRequest"
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @arrival_date = form[:arrival_date].to_s
    @num_nights = form[:num_nights].to_s
  end
  
  def valid_date
    temp = Date.parse(@arrival_date.to_s)

    if (temp <=> Date.today) >= 0
      return true 
    else
      errors.add(:base, "Arrival date is before today's date.")
      return false
    end
    
  rescue ArgumentError
    # Invalid dates (ie 1994-13-32) cannot be parsed and so will throw an ArugmentError
    errors.add(:base, "Arrival date could not be parsed or was invalid.")
    return false
  end
end