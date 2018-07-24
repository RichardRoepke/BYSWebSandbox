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
        update_billing_array(params[:calculate_form])
      else
        @billing = params[:calculate_form][:current_bill_num].to_i
        update_billing_array(params[:calculate_form])
        
        validator = CalculateValidator.new(params[:calculate_form])
        
        handle_user_action(validator, params[:user_action])
      end
    else
      @billing = 1
      @billing_index = ["0"]
      @billing_array = [["","",""]]
    end
  end
  
  def res_hold
    if params[:res_hold_form]
      @park = params[:res_hold_form][:park_ID].to_s
      @security = params[:res_hold_form][:security_key].to_s
      @reservation_ID = params[:res_hold_form][:reservation_ID].to_s
      
      @site_internal = params[:res_hold_form][:site][:internal_UID].to_s
      @site_type = params[:res_hold_form][:site][:type_ID].to_s
      
      @unit_internal = params[:res_hold_form][:unit][:internal_UID].to_s
      @unit_type = params[:res_hold_form][:unit][:type_ID].to_s
      @unit_length = params[:res_hold_form][:unit][:length].to_s
      
      @arrival = params[:res_hold_form][:date][:arrival_date].to_s
      @nights = params[:res_hold_form][:date][:num_nights].to_s
      
      @rate_ID = params[:res_hold_form][:rate_ID].to_s
      @member_UUID = params[:res_hold_form][:member_UUID].to_s
      
      @site1 = params[:res_hold_form][:site_choice][:site1].to_s
      @site2 = params[:res_hold_form][:site_choice][:site2].to_s
      @site3 = params[:res_hold_form][:site_choice][:site3].to_s
      
      @loyalty_code = params[:res_hold_form][:loyalty_code].to_s
      @loyalty_text = params[:res_hold_form][:loyalty_text].to_s
      @discount_code = params[:res_hold_form][:discount_code].to_s
      @discount_text = params[:res_hold_form][:discount_text].to_s
      
      @cust = params[:res_hold_form][:customer]
      @cust[:terms_accept] = string_to_boolean @cust[:terms_accept]

      if params[:user_action] == "Update"
        @billing = 1
        @billing = params[:res_hold_form][:bill_num].to_i if params[:res_hold_form][:bill_num].to_i > 0
        update_billing_array(params[:res_hold_form])
      else
        @billing = params[:res_hold_form][:current_bill_num].to_i
        update_billing_array(params[:res_hold_form])
        
        params[:res_hold_form][:customer][:terms_accept] = "0"
        params[:res_hold_form][:customer][:terms_accept] = "1" if @cust[:terms_accept]
        
        validator = ResHoldValidator.new(params[:res_hold_form])
        
        handle_user_action(validator, params[:user_action])
      end
    else
      @billing = 1
      @billing_index = ["0"]
      @billing_array = [["","",""]]
      @cust = { }
    end
  end
  
  def res_confirm
    if params[:res_confirm_form]
      @set = params[:res_confirm_form]
      validator = ResConfirmValidator.new(params[:res_confirm_form])
      
      handle_user_action(validator, params[:user_action]) if params[:user_action].present?
    else
      @set = {}
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
  
  def update_billing_array (form)
    @billing_index = []
    @billing_array = []
    @billing.times do |n|
      @billing_index.push(n.to_s)
      
      if form[@billing_index[n]].present?
         item = form[@billing_index[n]][:item]
         quantity = form[@billing_index[n]][:quantity]
         type = string_to_boolean form[@billing_index[n]][:type]
      else
        item = ""
        quantity = ""
        type = "0"
      end
      
      @billing_array.push([item, quantity, type])
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
