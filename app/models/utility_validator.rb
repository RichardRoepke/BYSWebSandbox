class UtilityValidator
  include ActiveModel::Validations

  attr_accessor :requestID
  attr_accessor :parkID
  attr_accessor :securityKey

  validates :requestID, inclusion: { in: %w{UnitTypeInfoRequest SiteTypeInfoRequest NotesAndTermsRequest}}
  validates :parkID, length: { is: 6}
  validates :parkID, format: { with: /\A^M.*\z/, message: "CampGroundUserName must start with a M" }
  validates :securityKey, presence: true
end