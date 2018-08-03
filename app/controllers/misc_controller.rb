class MiscController < ApplicationController
  include ApiHelper

  def xml_parse
    @output = {}

    if params[:input_form].present?
      @set = params[:input_form]

      if params[:user_action].present?
        if params[:user_action] == 'Submit XML'
          @output = xml_api_call('https://54.197.134.112:3400/' + @set[:request_ID], @set[:input])
        elsif params[:user_action] == 'Submit JSON'
          @output = json_api_call('https://54.197.134.112:3400/' + @set[:request_ID], @set[:input])
        end
      end
    else
      @set = {request_ID: "unittypeinfo"}
    end
  end


end
