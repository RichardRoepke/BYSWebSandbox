require 'builder'
require 'rexml/document'

class ServicesController < ApplicationController
  def utility
    if params[:utility_form]
      @request = params[:utility_form][:request_ID].to_s
      @park = params[:utility_form][:park_ID].to_s
      @security = params[:utility_form][:security_key].to_s
    else
      @request = "UnitTypeInfoRequest" 
      @park = ""
      @security = ""
    end
    
    resolve_user_action(params[:user_action], params[:utility_form], "UtilityService") if params[:user_action].present?
  end
  
  def availability
    if params[:availability_form]
      @park = params[:availability_form][:park_ID].to_s
      @security = params[:availability_form][:security_key].to_s
      @arrival = params[:availability_form][:arrival_date].to_s
      @nights = params[:availability_form][:num_nights].to_s
    else
      @park = ""
      @security = ""
      @arrival = ""
      @nights = ""
    end
    
    resolve_user_action(params[:user_action], params[:availability_form], "AvailabilityRequest") if params[:user_action].present?
  end
  
  def resolve_user_action(user_action, user_input, service_type)
    request_XML = generate_XML_if_valid(user_input, service_type)
    
    if request_XML.present?
      if user_action == "Check XML"
        @xml_title = "Service Request"
        @xml = request_XML
      elsif user_action == "Submit"
        service_response = Typhoeus::Request.post( generate_path(user_input, service_type), 
                                           headers: {'Content-Type' => 'text/xml'},
                                           body: request_XML,
                                           :ssl_verifyhost => 0 ) #Server is set as verified but without proper certification.
        
        # In certain cases Web Services may complete the connection but send
        # nothing in response. So a successful request doesn't mean a response
        # was received in return.
        if service_response.success? && service_response.response_body.present?
          @xml_title = "Service Response"
          @xml = service_response.response_body
          
          doc = REXML::Document.new @xml
          
          # Quick and simple way to find if a fault was sent by the server.
          doc.each_element("//Fault"){ |f|
            
            f.each_element("//FaultCode"){ |c|
              @xml_fault_title = "ERROR (" + c.text + "): "
              
              @xml_fault_help = generate_troubleshooting(c.text)
              }
            
            f.each_element("//FaultMessage") { |m|
              @xml_fault_title += m.text
              }
            }
        else
          # If the response succeeded but returned nothing.
          if service_response.success?
            @response_fail = "Connection was successful but web services responded with an empty message body. Please verify your inputs and try again."
          else
            @response_fail = serviceResponse.code.to_s
            @response_fail += ": " + serviceResponse.return_message unless serviceResponse.return_message == "No error"
          end
        end
      end
    end
  end # - resolve_user_action
  
  def generate_path(user_input, service_type)
    if service_type == "UtilityService"
      return "https://54.197.134.112:3400/" + user_input[:request_ID].to_s.chomp("Request").downcase
    end
  end
  
  def generate_XML_if_valid(user_input, service_type)
    output = nil
    
    validator = generate_validator(user_input, service_type)
  
    if validator.present?
      if validator.valid?
        output = build_request_XML(user_input, service_type)
      else
        @request_errors = validator.errors
      end
    end
    
    return output
  end
  
  def generate_validator(user_input, service_type)   
    if service_type == "UtilityService"
      return ServiceValidator.new(user_input)
    elsif service_type == "AvailabilityRequest"
      return AvailabilityValidator.new(user_input)
    else
      return nil
    end
  end
  
  def build_request_XML(user_input, service_type)
    if service_type == "UtilityService"
      return build_utility_XML(user_input[:request_ID], user_input[:park_ID], user_input[:security_key])
    else
      return nil
    end
  end
  
  def build_utility_XML(request, park, security)
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>"1.0" #:content_type=>"text/xml" #, :encoding=>"UTF-8"
    xml.tag!("Envelope", "xmlns:xsi"=>'http://www.w3.org/2001/XMLSchema-instance', "xsi:noNamespaceSchemaLocation"=>'file:/home/bys/Desktop/SHARE/xml2/' + request + '/' + utility_XSD_path(request) + '.xsd')  {
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
  end # - build_utility_XML
  
  def utility_XSD_path(request)
    if request == "UnitTypeInfoRequest"
      return "unitTypeInfoRequest"
    elsif request == "SiteTypeInfoRequest"
      return "siteTypeInfoRequest"
    else
      return request
    end
  end
  
  def generate_troubleshooting(error_code)
    unexpected = "Web services unexpectedly failed to validate your request. Please double-check that all of your inputs are correct."
    
    case error_code
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
  end # - generate_troubleshooting

end
