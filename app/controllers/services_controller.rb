require 'builder'
require 'rexml/document'

class ServicesController < ApplicationController
  def utility
    if params[:utility_form]
      @request = params[:utility_form][:request_ID].to_s
      @park = params[:utility_form][:park_ID].to_s
      @security = params[:utility_form][:security_key].to_s
      validator = UtilityValidator.new(params[:utility_form])
      
      handle_user_action(validator, params[:user_action]) if params[:user_action].present?
    else
      @request = "UnitTypeInfoRequest" 
      @park = ""
      @security = ""
    end
  end
  
  def availability
    if params[:availability_form]
      @park = params[:availability_form][:park_ID].to_s
      @security = params[:availability_form][:security_key].to_s
      @arrival = params[:availability_form][:arrival_date].to_s
      @nights = params[:availability_form][:num_nights].to_s
      @internal = params[:availability_form][:internal_UID].to_s
      @type = params[:availability_form][:type_ID].to_s
      @length = params[:availability_form][:unit_length].to_s
      
      @unavailable = false
      @unavailable = true if params[:availability_form][:request_unav].to_i == 1
      
      validator = AvailabilityValidator.new(params[:availability_form])
      
      handle_user_action(validator, params[:user_action]) if params[:user_action].present?
    else
      @park = ""
      @security = ""
      @arrival = ""
      @nights = ""
      @internal = ""
      @type = ""
      @length = ""
      @unavailable = false
    end
    
    #resolve_user_action(params[:user_action], params[:availability_form], "AvailabilityRequest") if params[:user_action].present?
  end
  
  def handle_user_action(validator, user_action)
    if validator.valid?
      validator.resolve_action(user_action)
      @request_errors = validator.output[:request_errors] if validator.output[:request_errors].present?
      @response_fail = validator.output[:response_fail] if validator.output[:response_fail].present?
      @xml = validator.output[:xml] if validator.output[:xml].present?
      @xml_title = validator.output[:xml_title] if validator.output[:xml_title].present?
      @xml_fault_title = validator.output[:xml_fault_title] if validator.output[:xml_fault_title].present?
      @xml_fault_help = validator.output[:xml_fault_help] if validator.output[:xml_fault_help].present?
    else
      @request_errors = validator.errors
    end
  end
end
