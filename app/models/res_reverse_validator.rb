require 'builder'

class ResReverseValidator < ServiceValidator

  attr_accessor :res_token

  validates :res_token, presence: { message: "Reservation Hold Token is required" }
  
  def initialize(form)
    @request_ID = "ReservationReversalRequest"
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @res_token = form[:res_token].to_s
    
    @output = Hash.new
  end
  
  def generate_path()
    return "https://54.197.134.112:3400/reservationreverse"
  end
  
  def build_XML()    
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!("Envelope", "xmlns:xsi"=>'http://www.w3.org/2001/XMLSchema-instance',
                         "xsi:noNamespaceSchemaLocation"=>'file:/home/bys/Desktop/SHARE/xml2/ReservationReversalRequest/reservationReversalRequest.xsd')  {
      xml.tag!("Body") {
        xml.tag!("reservationreverse"){
          xml.tag!("RequestData"){
            xml.tag!("RequestIdentification"){
              xml.ServiceRequestID @request_ID.to_s
              xml.tag!("CampGroundIdentification"){
                xml.CampGroundUserName @park_ID.to_s
                xml.CampGroundSecurityKey @security_key.to_s
              }
            }
            
            xml.tag!("ReservationReverseRequest"){
              xml.ReservationHoldToken @res_token.to_s
            }
          }
        }
      }
    }
  end # - build_XML
end