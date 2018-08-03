require 'builder'

class ServiceValidator
  include ActiveModel::Validations
  include ApiHelper

  attr_accessor :request_ID
  attr_accessor :park_ID
  attr_accessor :security_key
  attr_accessor :version_num
  attr_accessor :output

  validates :request_ID, inclusion: { in: %w{ UnitTypeInfoRequest SiteTypeInfoRequest NotesAndTermsRequest BYSPublicKeyRequest SiteAvailabilityRequest
                                              RateCalculationRequest ReservationHoldRequest ReservationConfirmRequest SiteUsageHoldRequest ReservationCreateRequest
                                              SiteUsageCancelRequest ReservationReversalRequest }, message: 'Non-valid Service Request ID.'}
  validates :park_ID, length: { is: 6, message: 'Camp Ground User Name must be exactly 6 characters'}
  validates :park_ID, format: { with: /\AM.*\z/, message: 'Camp Ground User Name must start with a M' }
  validates :park_ID, format: { with: /\A[a-zA-Z0-9_]*\z/, message: 'Camp Ground User Name can only be made out of alphanumeric characters.'}
  validates :version_num, format: { with: /\A[0-9]*\z/, message: 'Service Request Version must be a number if present.'}
  validates :security_key, presence: { message: 'Security Key is required' }
  # validates :security_key, format: { with: /\A^[a-zA-Z0-9_]*\z/, message: 'Security Key can only be made out of alphanumeric characters.'}
  validate  :version_value

  def initialize(form)
    @request_ID = form[:request_ID].to_s
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @version_num = form[:version_num].to_s

    @output = Hash.new
  end

  def version_value
    if @version_num.present?
      if @version_num.to_i > 0
        return true
      else
        errors.add(:base, 'Service Request Version must be greater than 0 if present.')
        return false
      end
    else
      return true # No version is acceptable.
    end
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
    if ['Check XML', 'Submit XML', 'Force XML'].include? user_action
      request_XML = build_XML

      if request_XML.present?
        if user_action == 'Check XML'
          output[:xml_title] = 'Service Request'
          output[:xml] = request_XML
        else
          @output = xml_api_call(generate_path, request_XML)
        end
      end
    elsif ['Check JSON', 'Submit JSON', 'Force JSON'].include? user_action
      request_JSON = build_JSON

      if request_JSON.present?
        if user_action == 'Check JSON'
          output[:xml_title] = 'Service Request'
          output[:xml] = request_JSON
        else
          @output = json_api_call(generate_path, request_JSON)
        end
      end
    end
  end # - resolve_user_action

  def build_JSON
    temp_hash = Hash.from_xml(build_XML)
    temp_hash["Envelope"].delete("xmlns:xsi")
    temp_hash["Envelope"].delete("xsi:noNamespaceSchemaLocation")
    temp_hash = json_recursive_reformat(temp_hash)
    json_result = JSON.pretty_generate(temp_hash)
    return json_result
  end

  def json_recursive_reformat (hash)
    result_hash = {}

    hash.each do |key, value|
      if value.kind_of?(Hash)
        # If the value is a hash with 1 key-value pair, check if that child is an array.
        # If so, we need to reformat the current key-value pair. Not the value's key-value key.
        if value.length == 1 && value.select{|k, v| v.kind_of?(Array)}.present?
          result_hash[key] = reformat_array(value)
        else
          result_hash[key] = json_recursive_reformat(value)
        end
      else
        result_hash[key] = value
      end
    end

    return result_hash
  end

  def reformat_array (array)
    result_array = []

    child_pair = array.shift

    child_pair[1].each do |content|
      temp_hash = { child_pair[0] => content }
      result_array.push temp_hash
    end

    return result_array
  end
end
