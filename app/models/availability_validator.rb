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
  validates :internal_UID, format: { with: /\A([0-9]*[1-9]){0,1}\z/, message: "Unit Type Internal ID must be empty or a number greater than 0."}
  validates :type_ID, format: { with: /\A^[a-zA-Z0-9_\-\\]*\z/, message: "Unit Type ID can only be alphanumeric characters, dashes, underscores and backslashes."}
  validates :unit_length, format: { with: /\A[0-9]*\z/, message: "Unit Length must be a number."}
  validates :request_unav, format: { with: /\A(0|1)\z/, message: "Request Unavailable must be 0 or 1."}
  
  validate  :valid_date
  validate  :UID_or_ID
  validate  :length_range
  
  def initialize(form)
    @request_ID = "SiteAvailabilityRequest"
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @arrival_date = form[:arrival_date].to_s
    @num_nights = form[:num_nights].to_s
    @internal_UID = form[:internal_UID].to_s
    @type_ID = form[:type_ID].to_s
    @unit_length = form[:unit_length].to_s
    @request_unav = form[:request_unav].to_s
    
    @output = Hash.new
  end
  
  def length_range
    unless @unit_length == ""
      if @unit_length.to_i < 1 || @unit_length.to_i > 100
        errors.add(:base, "At least one of Unit Type Internal ID and Unit Type ID must be present.")
        return false
      end
    end
    
    return true
  end
  
  def UID_or_ID
    if @internal_UID == "" && @type_ID == ""
      errors.add(:base, "At least one of Unit Type Internal ID and Unit Type ID must be present.")
      return false
    else
      return true
    end
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
  
  def generate_path()
    return "https://54.197.134.112:3400/siteavailability"
  end
  
  def build_XML()
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!("Envelope", "xmlns:xsi"=>'http://www.w3.org/2001/XMLSchema-instance', "xsi:noNamespaceSchemaLocation"=>'/home/bys/Desktop/SHARE/xml2/SiteAvailabilityRequest/siteAvailabilityRequest.xsd')  {
      xml.tag!("Body") {
        xml.tag!("siteavailability"){
          xml.tag!("RequestData"){
            xml.tag!("RequestIdentification"){
              xml.ServiceRequestID "SiteAvailabilityRequest"
              xml.tag!("CampGroundIdentification"){
                xml.CampGroundUserName @park_ID
                xml.CampGroundSecurityKey @security_key
              }
            }
            
            xml.tag!("AvailabilityRequest") {
              xml.ArrivalDate @arrival_date
              xml.NumberOfNights @num_nights
              xml.UnitTypeInternalUID @internal_UID unless @internal_UID == ""
              xml.UnitType @type_ID unless @type_ID == ""
              xml.UnitLength @unit_length unless @unit_length == ""
              xml.RequestUnavailables @request_unav
            }
          }
        }
      }
    }
  end # - build_availability_XML
end