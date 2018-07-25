class CalculateValidator < ServiceValidator
  include ActiveModel::Validations

  validate  :valid_date
  validate  :valid_site
  validate  :valid_billing
  
  def initialize(form)
    @site = SiteValidator.new( { internal_UID: "", type_ID: "" } )
    @date = DateValidator.new( { arrival_date: "", num_nights: "" } )
    @billing = BillingArrayValidator.new( form[:billing] )
    
    @request_ID = "SiteAvailabilityRequest"
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    
    @site.internal_UID = form[:internal_UID].to_s
    @site.type_ID = form[:type_ID].to_s
    @date.arrival_date = form[:arrival_date].to_s
    @date.num_nights = form[:num_nights].to_s
    
    @output = Hash.new
  end
  
  def valid_site
    if @site.valid?
      return true
    else
      @site.errors.each do |type, message|
        errors.add(:base, "Site " + message)
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
    return "https://54.197.134.112:3400/ratecalculation"
  end
  
  def build_XML()
    @internal_UID = @site.internal_UID.to_s
    @type_ID = @site.type_ID.to_s
    @arrival_date = @date.arrival_date.to_s
    @num_nights = @date.num_nights.to_s
    
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!("Envelope", "xmlns:xsi"=>'http://www.w3.org/2001/XMLSchema-instance', 
                         "xsi:noNamespaceSchemaLocation"=>'/home/bys/Desktop/SHARE/xml2/RateCalculationRequest/rateCalculationRequest.xsd')  {
      xml.tag!("Body") {
        xml.tag!("ratecalculation"){
          xml.tag!("RequestData"){
            xml.tag!("RequestIdentification"){
              xml.ServiceRequestID "RateCalculationRequest"
              xml.tag!("CampGroundIdentification"){
                xml.CampGroundUserName @park_ID
                xml.CampGroundSecurityKey @security_key
              }
            }
            
            xml.tag!("RateCalculationRequest") {
              xml.SiteTypeInternalUID @internal_UID unless @internal_UID == ""
              xml.SiteType @type_ID unless @type_ID == ""
              xml.ArrivalDate @arrival_date
              xml.NumberOfNights @num_nights
              xml.tag!("BillingDetails"){
                @billing.billing_array.each do |bill|
                  xml.tag!("BillingDetail"){
                    xml.BillingItem bill.item.to_s
                    xml.BillingItemType bill.type.to_s
                    xml.BillingQty bill.quantity.to_s
                  }
                end
              }
            }
          }
        }
      }
    }
  end # - build_XML
end