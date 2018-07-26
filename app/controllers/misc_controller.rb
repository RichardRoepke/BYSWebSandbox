class MiscController < ApplicationController
  include ApiHelper
  
  def xml_parse
    if params[:input_form].present?
      @set = params[:input_form]
      
      if params[:user_action].present?
        output = api_call('https://54.197.134.112:3400/' + @set[:request_ID], @set[:xml])
        @request_errors = output[:request_errors] if output[:request_errors].present?
        @response_fail = output[:response_fail] if output[:response_fail].present?
        @xml = output[:xml] if output[:xml].present?
        @xml_title = output[:xml_title] if output[:xml_title].present?
        @xml_fault_title = output[:xml_fault_title] if output[:xml_fault_title].present?
        @xml_fault_help = output[:xml_fault_help] if output[:xml_fault_help].present?
      end
    else
      @set = {request_ID: "unittypeinfo"}
    end
  end
  
  
end
