class MiscController < ApplicationController
  include ApiHelper

  def text_parse
    @output = {}

    if params[:input_form].present?
      @set = params[:input_form]

      if params[:user_action].present?
        if params[:user_action] == 'Submit XML'
          @output = api_call('https://54.197.134.112:3400/' + @set[:request_ID], @set[:input], 'XML')
        elsif params[:user_action] == 'Submit JSON'
          @output = api_call('https://54.197.134.112:3400/' + @set[:request_ID], @set[:input], 'JSON')
        end
      end
    else
      @set = {request_ID: "unittypeinfo"}
    end
  end


end
