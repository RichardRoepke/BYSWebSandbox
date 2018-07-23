class CalculateValidator < ServiceValidator
  include ActiveModel::Validations

  validate  :valid_date
  validate  :valid_unit
  validate  :valid_billing
  
  def initialize(form)
    @unit = UnitValidator.new( { internal_UID: "", type_ID: "", unit_length: "" } )
    @date = DateValidator.new( { arrival_date: "", num_nights: "" } )
    
    @request_ID = "SiteAvailabilityRequest"
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    
    @unit.internal_UID = form[:internal_UID].to_s
    @unit.type_ID = form[:type_ID].to_s
    @unit.length = form[:unit_length].to_s
    @date.arrival_date = form[:arrival_date].to_s
    @date.num_nights = form[:num_nights].to_s
    
    @billing_array = []
    
    form[:current_bill_num].to_i.times do |n|
      billing = { item: form[("item" + n.to_s).to_sym], 
                  type: form[("type" + n.to_s).to_sym],
                  quantity: form[("quantity" + n.to_s).to_sym] }
      
      @billing_array.push(BillingValidator.new(billing))
    end
    
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
  
  def valid_billing
    result = true
    
    @billing_array.each do |bill|
      result = false unless bill.valid?
    end
    
    return result
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