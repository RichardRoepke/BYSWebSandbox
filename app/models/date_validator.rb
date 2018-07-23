require 'date'

class DateValidator
  include ActiveModel::Validations
  
  attr_accessor :arrival_date
  attr_accessor :num_nights
  
  validates :arrival_date, format: { with: /\A[0-9\-]*\z/, message: "Arrival Date can only be numbers and dashes."}
  validates :arrival_date, format: { with: /\A....\-..\-..\z/, message: "Arrival Date must be in the format of YYYY-MM-DD."}
  validates :num_nights, presence: { message: "Number of nights is required." }
  validates :num_nights, format: { with: /\A\-*[0-9]*\z/, message: "Number of Nights must be a number."}
  
  validate  :valid_date
  validate  :num_nights_value
  
  def initialize(form)
    @arrival_date = form[:arrival_date].to_s
    @num_nights = form[:num_nights].to_s
  end
  
  def num_nights_value
    if @num_nights.to_i > 0
      return true
    else
      errors.add(:base, "Number of Nights must be greater than 0.")
      return false
    end
    
    return true
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