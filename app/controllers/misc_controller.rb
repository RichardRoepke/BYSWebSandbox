class MiscController < ApplicationController
  include ApiHelper

  def xml_parse
    @output = {}

    if params[:input_form].present?
      @set = params[:input_form]

      if params[:user_action].present?
        @output = api_call('https://54.197.134.112:3400/' + @set[:request_ID], @set[:xml])
      end
    else
      @set = {request_ID: "unittypeinfo"}
    end
  end


end
