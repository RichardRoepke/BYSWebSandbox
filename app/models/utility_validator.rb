class UtilityValidator
  include ActiveModel::Validations

  attr_accessor :requestID
  attr_accessor :parkID
  attr_accessor :securityKey

  validates :requestID, inclusion: { in: %w{UnitTypeInfoRequest SiteTypeInfoRequest NotesAndTermsRequest}}
  validates :parkID, length: { is: 6, message: "Camp Ground User Name must be 6 characters"}
  validates :parkID, format: { with: /\A^M.*\z/, message: "Camp Ground User Name must start with a M" }
  validates :securityKey, presence: { message: "Security Key is required" }
end