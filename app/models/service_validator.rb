require 'builder'

class ServiceValidator
  include ActiveModel::Validations
  include ApiHelper

  attr_accessor :request_ID
  attr_accessor :park_ID
  attr_accessor :security_key
  attr_accessor :output

  validates :request_ID, inclusion: { in: %w{ UnitTypeInfoRequest SiteTypeInfoRequest NotesAndTermsRequest BYSPublicKeyRequest SiteAvailabilityRequest 
                                              RateCalculationRequest ReservationHoldRequest ReservationConfirmRequest SiteUsageHoldRequest ReservationCreateRequest
                                              SiteUsageCancelRequest ReservationReversalRequest }, message: 'Non-valid Service Request ID.'}
  validates :park_ID, length: { is: 6, message: 'Camp Ground User Name must be exactly 6 characters'}
  validates :park_ID, format: { with: /\AM.*\z/, message: 'Camp Ground User Name must start with a M' }
  validates :park_ID, format: { with: /\A[a-zA-Z0-9_]*\z/, message: 'Camp Ground User Name can only be made out of alphanumeric characters.'}
  validates :security_key, presence: { message: 'Security Key is required' }
  # validates :security_key, format: { with: /\A^[a-zA-Z0-9_]*\z/, message: 'Security Key can only be made out of alphanumeric characters.'}

  def initialize(form)
    @request_ID = form[:request_ID].to_s
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s

    @output = Hash.new
  end
  
  def objectvalidation(object, garnish)
    if object.valid?
      return true
    else
      object.errors.each do |type, message|
        errors.add(:base, garnish + message)
      end
      return false
    end
  end

  def resolve_action(user_action)
    request_XML = build_XML()

    if request_XML.present?
      if user_action == 'Check XML'
        output[:xml_title] = 'Service Request'
        output[:xml] = request_XML
      elsif user_action == 'Submit' || user_action == 'Force Submit'
        @output = api_call(generate_path, request_XML)
      end
    end
  end # - resolve_user_action
end
