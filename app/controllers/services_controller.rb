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
  end
  
  def calculate
    if params[:calculate_form]
      @park = params[:calculate_form][:park_ID].to_s
      @security = params[:calculate_form][:security_key].to_s
      @internal = params[:calculate_form][:internal_UID].to_s
      @type = params[:calculate_form][:type_ID].to_s
      @arrival = params[:calculate_form][:arrival_date].to_s
      @nights = params[:calculate_form][:num_nights].to_s
      
      if params[:user_action] == "Update"
        @billing = 1
        @billing = params[:calculate_form][:bill_num].to_i if params[:calculate_form][:bill_num].to_i > 0
        update_billing_array
      else
        @billing = params[:calculate_form][:current_bill_num].to_i
        update_billing_array
        
        validator = CalculateValidator.new(params[:calculate_form])
        
        handle_user_action(validator, params[:user_action])
      end
    else
      @park = ""
      @security = ""
      @internal = ""
      @type = ""
      @arrival = ""
      @nights = ""
      @billing = 1
      @billing_index = [0]
      @billing_array = [["","",""]]
    end
  end
  
  def handle_user_action(validator, user_action)
    if validator.valid? || user_action == "Force Submit"
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
  
  def update_billing_array ()
    @billing_index = []
        @billing_array = []
        @billing.times do |n|
          @billing_index.push(n.to_i)
          temp = string_to_boolean params[:calculate_form][("type" + n.to_s).to_sym]
          @billing_array.push([params[:calculate_form][("item" + n.to_s).to_sym], 
                               params[:calculate_form][("quantity" + n.to_s).to_sym], 
                               temp ])
        end
  end
  
  def string_to_boolean(string)
    if string == "1"
      return true
    else
      return false
    end
  end
end
