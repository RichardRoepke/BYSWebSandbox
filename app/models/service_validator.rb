require 'builder'

class ServiceValidator
  include ActiveModel::Validations

  attr_accessor :request_ID
  attr_accessor :park_ID
  attr_accessor :security_key
  attr_accessor :output

  validates :request_ID, inclusion: { in: %w{UnitTypeInfoRequest SiteTypeInfoRequest NotesAndTermsRequest BYSPublicKeyRequest SiteAvailabilityRequest RateCalculationRequest ReservationHoldRequest}, message: "Non-valid Service Request ID."}
  validates :park_ID, length: { is: 6, message: "Camp Ground User Name must be exactly 6 characters"}
  validates :park_ID, format: { with: /\AM.*\z/, message: "Camp Ground User Name must start with a M" }
  validates :park_ID, format: { with: /\A[a-zA-Z0-9_]*\z/, message: "Camp Ground User Name can only be made out of alphanumeric characters."}
  validates :security_key, presence: { message: "Security Key is required" }
  #validates :security_key, format: { with: /\A^[a-zA-Z0-9_]*\z/, message: "Security Key can only be made out of alphanumeric characters."}
  
  
  def initialize(form)
    if form.present?
      @request_ID = form[:request_ID].to_s
      @park_ID = form[:park_ID].to_s
      @security_key = form[:security_key].to_s
    else
      @request_ID = ""
      @park_ID = ""
      @security_key = ""
    end
    
    @output = Hash.new
  end
  
  def resolve_action(user_action)
    request_XML = build_XML()
    
    if request_XML.present?
      if user_action == "Check XML"
        output[:xml_title] = "Service Request"
        output[:xml] = request_XML
      elsif user_action == "Submit" || user_action == "Force Submit"
        service_response = Typhoeus::Request.post( generate_path(), 
                                           headers: {'Content-Type' => 'text/xml'},
                                           body: request_XML,
                                           :ssl_verifyhost => 0 ) #Server is set as verified but without proper certification.
        
        # In certain cases Web Services may complete the connection but send
        # nothing in response. So a successful request doesn't mean a response
        # was received in return.
        if service_response.success? && service_response.response_body.present?
          output[:xml_title] = "Service Response"
          output[:xml] = service_response.response_body
          
          doc = REXML::Document.new output[:xml]
          
          # Quick and simple way to find if a fault was sent by the server.
          doc.each_element("//Fault"){ |f|
            
            f.each_element("//FaultCode"){ |c|
              output[:xml_fault_title] = "ERROR (" + c.text + ")"
              
              output[:xml_fault_help] = generate_troubleshooting(c.text)
              }
            
            f.each_element("//FaultMessage") { |m|
              
              output[:xml_fault_title] += ": " + m.text if m.has_text?
              }
            }
        else
          # If the response succeeded but returned nothing.
          if service_response.success?
            output[:response_fail] = "Connection was successful but web services responded with an empty message body. Please verify your inputs and try again."
          else
            output[:response_fail] = service_response.code.to_s
            output[:response_fail] += ": " + service_response.return_message unless service_response.return_message == "No error"
          end
        end
      end
    end
  end # - resolve_user_action
  
  def generate_troubleshooting(error_code)
    unexpected = "Web services unexpectedly failed to validate your request. Please double-check that all of your inputs are correct."
    
    case error_code
    when "BYSVV00" then "The Sandbox did not attach the correct XML to the server request."
    when "BYSVV01" then "DebugInfo should correspond to the text in ServiceRequestID in your request. Double-check that the two are identical and are both valid requests."
    when "BYSVV02" then "This is likely a web services issue. Please reload the page and try again."
    when "BYSVV03" then "Double check that your Camp Ground User Name is correct and try again."
    when "BYSVV04" then "Double check that your security key and/or login credentials are correct and try again."
    when "BYSSA05" then unexpected
    when "BYSVV99" then unexpected
    when "BYSUT99" then unexpected
    when "BYSST99" then unexpected
    when "BYSNT99" then unexpected
    when "BYSUK99" then unexpected
    when "BYSRC99" then unexpected
    else nil
    end
  end # - generate_troubleshooting
end