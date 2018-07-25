class ResCreateValidator < ServiceValidator
  
  attr_accessor :usage_token
  
  validates :usage_token, presence: { message: "Site Usage Hold Token must be present." }
  
  validate  :valid_customer
  validate  :valid_billing
  
  def initialize(form)
    @customer = CustomerValidator.new( form[:customer] )
    
    @request_ID = "ReservationCreateRequest"
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @usage_token = form[:usage_token].to_s
    @billing = BillingArrayValidator.new( form[:billing] )
    
    @output = Hash.new
  end
  
  def valid_customer
    if @customer.valid?
      return true
    else
      @customer.errors.each do |type, message|
        errors.add(:base, message)
      end
      return false
    end
  end
  
  def valid_billing
    if @billing.valid?
      return true
    else
      @billing.errors.each do |type, message|
        errors.add(:base, message)
      end
      return false
    end
  end
  
  def generate_path()
    return "https://54.197.134.112:3400/reservationcreate"
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
  end # - build_XML
end