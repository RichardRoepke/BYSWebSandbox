class CustomerValidator
  include ActiveModel::Validations
  
  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :email
  attr_accessor :phone
  attr_accessor :phone_alt
  attr_accessor :address_one
  attr_accessor :address_two # Always included but not validated.
  attr_accessor :city
  attr_accessor :state_province
  attr_accessor :postal_code
  attr_accessor :note # Not always included and not validated.
  attr_accessor :terms_accept
  attr_accessor :cc_type
  attr_accessor :cc_number # No clue how to check for encryption.
  attr_accessor :cc_expiry

  # Web services doesn't seem to check/validate these values so no point
  # doing so in the sandbox either.
  validates :first_name, presence: { message: "First name is required." }
  validates :last_name, presence: { message: "Last name is required." }
  validates :email, presence: { message: "Email is required." }
  validates :address_one, presence: { message: "Address Line One is required."} 
  validates :city, presence: { message: "City is required." }
  validates :state_province, presence: { message: "State or Province is required." }
  validates :cc_number, presence: { message: "Credit Card Encrypted Number is required." }
  # Might be a good idea to implement validation later on down the line.
  
  validates :phone, format: { with: /\A[0-9\-]*\z/, message: "Phone Number can only be numbers and dashes." }
  validates :phone, format: { with: /\A...\-...\-....\z/, message: "Phone Number must be in the format of NNN-NNN-NNNN." }
  validates :phone_alt, format: { with: /\A[0-9\-]*\z/, message: "Alternate Phone Number can only be numbers and dashes." }
  validates :phone_alt, format: { with: /\A(...\-...\-....){0,1}\z/, message: "Alternate Phone Number must be in the format of NNN-NNN-NNNN if present." }
  validates :postal_code, format: { with: /\A[0-9A-Z]*\z/, message: "Zip/Postal code can only be numbers and upper case characters. No spaces are allowed." }
  validates :postal_code, format: { with: /\A([0-9]{5}|([A-Z][0-9]){3})\z/, message: "Zip/Postal code must be a valid US zip code (NNNNN) or Canadian postal code (XNXNXN)." }
  validates :terms_accept, format: { with: /\A(0|1)\z/, message: "Terms and Conditions Accepted must be 0 or 1." }
  validates :cc_type, format: { with: /\A(VISA|MC)\z/, message: "Credit Card Type must be VISA or MC." }
  validates :cc_expiry, format: { with: /\A[0-9\/]*\z/, message: "Credit Card Expiry can only be numbers and backslashes." }
  validates :cc_expiry, format: { with: /\A..\/..\z/, message: "Credit Card Expiry must be in the format XX/YY." }

  
  def initialize(form)
    @first_name = form[:first_name].to_s
    @last_name = form[:last_name].to_s
    @email = form[:email].to_s
    @phone = form[:phone].to_s
    @phone_alt = form[:phone_alt].to_s
    @address_one = form[:address_one].to_s
    @address_two = form[:address_two].to_s
    @city = form[:city].to_s
    @state_province = form[:state_province].to_s
    @postal_code = form[:postal_code].to_s
    @note = form[:note].to_s
    @cc_type = form[:cc_type].to_s
    @cc_number = form[:cc_number].to_s
    @cc_expiry = form[:cc_expiry].to_s
    
    @terms_accept = "0"
    @terms_accept = "1" if form[:terms_accept]
  end
end