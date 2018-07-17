require 'builder'

class UtilityServicesController < ApplicationController
  def generic
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
      if params[:info] == "Check XML"
        @xmlshow = true
      else
        @xmlshow = false
      end
      
      if params[:info] == "Check XML" || params[:info] == "Submit"
        request_valid = UtilityValidator.new
        request_valid.requestID = @request
        request_valid.parkID = @park
        request_valid.securityKey = @security
        
        @request_xml = buildXML if request_valid.valid?
        
        unless request_valid.valid?
          @errors = request_valid.errors
        end
      else
        @request_xml = nil
      end
      
      if params[:info] == "Submit" && @request_xml.present?
        puts "Yep."
      end
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
