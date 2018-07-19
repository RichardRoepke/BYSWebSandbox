require 'builder'
require 'rexml/document'

class ServicesController < ApplicationController
  def utility
    if params[:utility_form]
      @request = params[:utility_form][:requestID].to_s
      @park = params[:utility_form][:parkID].to_s
      @security = params[:utility_form][:securityKey].to_s
    else
      @request = "UnitTypeInfoRequest" 
      @park = ""
      @security = ""
    end
    
    resolveUserAction(params[:userAction], params[:utility_form], "UtilityService") if params[:userAction].present?
  end
  
  def availability
    if params[:utility_form]
      @request = params[:utility_form][:requestID].to_s
      @park = params[:utility_form][:parkID].to_s
      @security = params[:utility_form][:securityKey].to_s
    else
      @request = "UnitTypeInfoRequest" 
      @park = ""
      @security = ""
    end
    
    resolveUserAction(params[:userAction], params[:availability_form], "AvailabilityRequest") if params[:userAction].present?
  end
  
  def resolveUserAction(userAction, userInput, serviceType)
    requestXML = generateXMLIfValid(userInput, serviceType)
    
    if requestXML.present?
      if userAction == "Check XML"
        @xmltitle = "Service Request"
        @xml = requestXML
      elsif userAction == "Submit"
        serviceResponse = Typhoeus::Request.post( generatePath(userInput, serviceType), 
                                           headers: {'Content-Type' => 'text/xml'},
                                           body: requestXML,
                                           :ssl_verifyhost => 0 ) #Server is set as verified but without proper certification.
        
        # In certain cases Web Services may complete the connection but send
        # nothing in response. So a successful request doesn't mean a response
        # was received in return.
        if serviceResponse.success? && serviceResponse.response_body.present?
          @xmltitle = "Service Response"
          @xml = serviceResponse.response_body
          
          doc = REXML::Document.new @xml
          
          # Quick and simple way to find if a fault was sent by the server.
          doc.each_element("//Fault"){ |f|
            
            f.each_element("//FaultCode"){ |c|
              @xmlfaulttitle = "ERROR (" + c.text + "): "
              
              @xmlfaulthelp = generateTroubleshooting(c.text)
              }
            
            f.each_element("//FaultMessage") { |m|
              @xmlfaulttitle += m.text
              }
            }
        else
          if serviceResponse.success?
            @responsefail = "Connection was successful but web services responded with an empty message body. Please verify your inputs and try again."
          else
            @responsefail = serviceResponse.code.to_s
            @responsefail += ": " + serviceResponse.return_message unless serviceResponse.return_message == "No error"
          end
        end
      end
    end
  end # - resolveAction
  
  def generatePath(userInput, serviceType)
    if serviceType == "UtilityService"
      return "https://54.197.134.112:3400/" + userInput[:requestID].to_s.chomp("Request").downcase
    end
  end
  
  def generateXMLIfValid(userInput, serviceType)
    output = nil
    
    validator = generateValidator(userInput, serviceType)
  
    if validator.present?
      if validator.valid?
        output = buildRequestXML(userInput, serviceType)
      else
        @requesterrors = validator.errors
      end
    end
    
    return output
  end
  
  def generateValidator(userInput, serviceType)   
    if serviceType == "UtilityService"
      return UtilityValidator.new(userInput)
    else
      return nil
    end
  end
  
  def buildRequestXML(userInput, serviceType)
    if serviceType == "UtilityService"
      return buildUtilityXML(userInput[:requestID], userInput[:parkID], userInput[:securityKey])
    else
      return nil
    end
  end
  
  def buildUtilityXML(request, park, security)
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>"1.0" #:content_type=>"text/xml" #, :encoding=>"UTF-8"
    xml.tag!("Envelope", "xmlns:xsi"=>'http://www.w3.org/2001/XMLSchema-instance', "xsi:noNamespaceSchemaLocation"=>'file:/home/bys/Desktop/SHARE/xml2/' + request + '/' + utilityXSDPath(request) + '.xsd')  {
      xml.tag!("Body") {
        xml.tag!(request.chomp("Request").downcase){
          xml.tag!("RequestData"){
            xml.tag!("RequestIdentification"){
              xml.ServiceRequestID request
              xml.tag!("CampGroundIdentification"){
                xml.CampGroundUserName park
                xml.CampGroundSecurityKey security
              }
            }
          }
        }
      }
    }
  end # - buildUtilityXML
  
  def utilityXSDPath(request)
    if request == "UnitTypeInfoRequest"
      return "unitTypeInfoRequest"
    elsif request == "SiteTypeInfoRequest"
      return "siteTypeInfoRequest"
    else
      return request
    end
  end
  
  def generateTroubleshooting(errorcode)
    unexpected = "Web services unexpectedly failed to validate your request. Please double-check that all of your inputs are correct."
    
    case errorcode
    when "BYSVV00" then "The Sandbox did not attach the correct XML to the server request."
    when "BYSVV01" then "DebugInfo should correspond to the text in ServiceRequestID in your request. Double-check that the two are identical and are both valid requests."
    when "BYSVV02" then "This is likely a web services issue. Please reload the page and try again."
    when "BYSVV03" then "Double check that your Camp Ground User Name is correct and try again."
    when "BYSVV04" then "Double check that your security key and/or login credentials are correct and try again."
    when "BYSVV99" then unexpected
    when "BYSUT99" then unexpected
    when "BYSST99" then unexpected
    when "BYSNT99" then unexpected
    when "BYSUK99" then unexpected
    else nil
    end
  end # - generateTroubleshooting

end
