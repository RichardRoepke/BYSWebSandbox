require 'builder'
require 'rexml/document'

class UtilityServicesController < ApplicationController
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
    
    if params[:info]
      request_valid = UtilityValidator.new
      request_valid.requestID = @request
      request_valid.parkID = @park
      request_valid.securityKey = @security
        
      if request_valid.valid?
        @request_xml = buildXML
      else
        @requesterrors = request_valid.errors
      end
    end
      
    if @request_xml.present?
      if params[:info] == "Check XML"
        @xml = @request_xml
        @xmltitle = "Request"
      elsif params[:info] == "Submit"
        response = Typhoeus::Request.post( "https://54.197.134.112:3400/" + @request.chomp("Request").downcase, 
                                           headers: {'Content-Type' => 'text/xml'},
                                           body: @request_xml.to_s,
                                           :ssl_verifyhost => 0 )
                                           
        if response.success? && response.response_body.present?
          @xmltitle = "Response"
          @xml = response.response_body
          
          doc = REXML::Document.new @xml
          doc.each_element("//Fault"){ |f|
            
            @xmlfaulttitle = "ERROR (" + f.children[1].text + "): " + f.children[3].text
            @xmlfaulttext = errorHelp(f.children[1].text)
            
            }
          
        else
          if response.success?
            @responsefail = "Connection was successful but web services responded with an empty message body. Please verify your inputs and try again."
          else
            @responsefail = response.code.to_s
            @responsefail += ": " + response.return_message unless response.return_message == "No error"
          end
        end
        #puts "=======================RESPOND========================="
        #puts response.success?
        #puts response.code.to_s + ": " + response.return_message
        #puts response.response_body.to_s
      end
    end
  end
  
  def errorHelp(errorcode)
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
  end

  def buildXML
    xml = Builder::XmlMarkup.new(:target => @request_xml, :indent=>2)
    xml.instruct! :xml, :version=>"1.0" #:content_type=>"text/xml" #, :encoding=>"UTF-8"
    xml.tag!("Envelope", "xmlns:xsi"=>'http://www.w3.org/2001/XMLSchema-instance', "xsi:noNamespaceSchemaLocation"=>'file:/home/bys/Desktop/SHARE/xml2/SiteTypeInfoRequest/siteTypeInfoRequest.xsd')  {
      xml.tag!("Body") {
        xml.tag!(@request.chomp("Request").downcase){
          xml.tag!("RequestData"){
            xml.tag!("RequestIdentification"){
              xml.ServiceRequestID @request
              xml.tag!("CampGroundIdentification"){
                xml.CampGroundUserName @park
                xml.CampGroundSecurityKey @security
              }
            }
          }
        }
      }
    }
  end

end
