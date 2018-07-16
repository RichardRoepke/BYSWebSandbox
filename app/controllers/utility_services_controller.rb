class UtilityServicesController < ApplicationController
  def generic
    if params[:info]
      puts "It works!"
      @request = params[:utility_form][:requestID].to_s
      @park = params[:utility_form][:parkID].to_s
      @security = params[:utility_form][:securityKey].to_s
    else 
      @request = "UnitTypeInfoRequest" 
      @park = ""
      @security = ""
    end
  end

end
