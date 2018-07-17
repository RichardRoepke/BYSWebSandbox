class UtilityValidator
  include ActiveModel::Validations

  attr_accessor :requestID
  attr_accessor :parkID
  attr_accessor :securityKey

  validates :requestID, inclusion: { in: %w{UnitTypeInfoRequest SiteTypeInfoRequest NotesAndTermsRequest}}
  validates :parkID, length: { is: 6, message: "Camp Ground User Name must be 6 characters"}
  validates :parkID, format: { with: /\A^M.*\z/, message: "Camp Ground User Name must start with a M" }
  validates :parkID, format: { with: /\A^[a-zA-Z0-9_]*\z/, message: "Camp Ground User Name can only be made out of alphanumeric characters."}
  validates :securityKey, presence: { message: "Security Key is required" }
  #validates :securityKey, format: { with: /\A^[a-zA-Z0-9_]*\z/, message: "Security Key can only be made out of alphanumeric characters."}
end