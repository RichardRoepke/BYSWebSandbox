class AvailabilityValidator < ServiceValidator
  include ActiveModel::Validations
  
  attr_accessor :request_unav
  
  validates :request_unav, format: { with: /\A(0|1)\z/, message: "Request Unavailable must be 0 or 1."}
  
  validate  :valid_date
  validate  :valid_unit
  
  def initialize(form)
    @unit = UnitValidator.new( { internal_UID: "", type_ID: "", unit_length: "" } )
    @date = DateValidator.new( { arrival_date: "", num_nights: "" } )
    
    @request_ID = "SiteAvailabilityRequest"
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @request_unav = form[:request_unav].to_s
    
    @unit.internal_UID = form[:internal_UID].to_s
    @unit.type_ID = form[:type_ID].to_s
    @unit.length = form[:unit_length].to_s
    @date.arrival_date = form[:arrival_date].to_s
    @date.num_nights = form[:num_nights].to_s
    
    @output = Hash.new
  end
  
  def valid_unit
    if @unit.valid?
      return true
    else
      @unit.errors.each do |type, message|
        errors.add(:base, "Unit " + message)
      end
      return false
    end
  end
  
  def valid_date
    if @date.valid?
      return true
    else
      @date.errors.each do |type, message|
        errors.add(:base, message)
      end
      return false
    end
  end
  
  def generate_path()
    return "https://54.197.134.112:3400/siteavailability"
  end
  
  def build_XML()
    @internal_UID = @unit.internal_UID.to_s
    @type_ID = @unit.type_ID.to_s
    @unit_length = @unit.length.to_s
    @arrival_date = @date.arrival_date.to_s
    @num_nights = @date.num_nights.to_s
    
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!("Envelope", "xmlns:xsi"=>'http://www.w3.org/2001/XMLSchema-instance',
                         "xsi:noNamespaceSchemaLocation"=>'/home/bys/Desktop/SHARE/xml2/SiteAvailabilityRequest/siteAvailabilityRequest.xsd')  {
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
  end # - build_XML
end