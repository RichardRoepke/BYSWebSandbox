require "rexml/document"

module ApiHelper
  def api_call(path, xml)
    output = {}
    
    service_response = Typhoeus::Request.post( path,
                                           headers: {'Content-Type' => 'text/xml'},
                                           body: xml,
                                           :ssl_verifyhost => 0 ) #Server is set as verified but without proper certification.

        # In certain cases Web Services may complete the connection but send
        # nothing in response. So a successful request doesn't mean a response
        # was received in return.
        if service_response.success? && service_response.response_body.present?
          output[:xml_title] = 'Service Response'
          output[:xml] = service_response.response_body

          doc = REXML::Document.new output[:xml]

          # Quick and simple way to find if a fault was sent by the server.
          doc.each_element('//Fault'){ |f|

            f.each_element('//FaultCode'){ |c|
              output[:xml_fault_title] = 'ERROR'
              output[:xml_fault_title] = 'ERROR (' + c.text + ')' if c.has_text?
              
              output[:xml_fault_help] = generate_troubleshooting(c.text)
              }

            f.each_element('//FaultMessage') { |m|

              output[:xml_fault_title] += ': ' + m.text if m.has_text?
              }
            }
        else
          # If the response succeeded but returned nothing.
          if service_response.success?
            output[:response_fail] = 'Connection was successful but web services responded with an empty message body. Please verify your inputs and try again.'
          else
            output[:response_fail] = service_response.code.to_s
            output[:response_fail] += ': ' + service_response.return_message unless service_response.return_message == 'No error'
          end
        end
        
        return output
  end
  
  def generate_troubleshooting(error_code)
    unexpected = 'Web services unexpectedly failed to validate your request. Please double-check that all of your inputs are correct.'

    case error_code
    when 'BYSVV00' then 'The Sandbox did not attach the correct XML to the server request.'
    when 'BYSVV01' then 'DebugInfo should correspond to the text in ServiceRequestID in your request. Double-check that the two are identical and are both valid requests.'
    when 'BYSVV02' then 'This is likely a web services issue. Please reload the page and try again.'
    when 'BYSVV03' then 'Double check that your Camp Ground User Name is correct and try again.'
    when 'BYSVV04' then 'Double check that your security key and/or login credentials are correct and try again.'
    when 'BYSSA05' then unexpected
    when 'BYSVV99' then unexpected
    when 'BYSUT99' then unexpected
    when 'BYSST99' then unexpected
    when 'BYSNT99' then unexpected
    when 'BYSUK99' then unexpected
    when 'BYSRC99' then unexpected
    when 'BYSSHXX' then unexpected
    else nil
    end
  end # - generate_troubleshooting
end