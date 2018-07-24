class UtilityValidator < ServiceValidator
  include ActiveModel::Validations
  
  def build_XML()    
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!("Envelope", "xmlns:xsi"=>'http://www.w3.org/2001/XMLSchema-instance', "xsi:noNamespaceSchemaLocation"=>'file:/home/bys/Desktop/SHARE/xml2/' + @request_ID.to_s + '/' + XSD_path() + '.xsd')  {
      xml.tag!("Body") {
        xml.tag!(@request_ID.to_s.chomp("Request").downcase){
          xml.tag!("RequestData"){
            xml.tag!("RequestIdentification"){
              xml.ServiceRequestID @request_ID.to_s
              xml.tag!("CampGroundIdentification"){
                xml.CampGroundUserName @park_ID.to_s
                xml.CampGroundSecurityKey @security_key.to_s
              }
            }
          }
        }
      }
    }
  end # - build_XML
  
  def XSD_path()
    if @request_ID == "UnitTypeInfoRequest"
      return "unitTypeInfoRequest"
    elsif @request_ID == "SiteTypeInfoRequest"
      return "siteTypeInfoRequest"
    else
      return @request_ID
    end
  end
  
  def generate_path()
    return "https://54.197.134.112:3400/" + @request_ID.to_s.chomp("Request").downcase
  end
end 