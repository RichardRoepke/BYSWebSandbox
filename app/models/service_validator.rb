class ServiceValidator
  include ActiveModel::Validations

  attr_accessor :request_ID
  attr_accessor :park_ID
  attr_accessor :security_key

  validates :request_ID, inclusion: { in: %w{UnitTypeInfoRequest SiteTypeInfoRequest NotesAndTermsRequest BYSPublicKeyRequest SiteAvailabilityRequest}, message: "Non-valid Service Request ID."}
  validates :park_ID, length: { is: 6, message: "Camp Ground User Name must be exactly 6 characters"}
  validates :park_ID, format: { with: /\A^M.*\z/, message: "Camp Ground User Name must start with a M" }
  validates :park_ID, format: { with: /\A^[a-zA-Z0-9_]*\z/, message: "Camp Ground User Name can only be made out of alphanumeric characters."}
  validates :security_key, presence: { message: "Security Key is required" }
  #validates :security_key, format: { with: /\A^[a-zA-Z0-9_]*\z/, message: "Security Key can only be made out of alphanumeric characters."}
  
  
  def initialize(form)
    @request_ID = form[:request_ID].to_s
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
  end
end