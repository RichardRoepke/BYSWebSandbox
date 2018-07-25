require 'builder'
require 'rexml/document'

class ServicesController < ApplicationController
  def utility
    if params[:utility_form]
      @set = params[:utility_form]
      validator = UtilityValidator.new(params[:utility_form])
      
      handle_user_action(validator, params[:user_action]) if params[:user_action].present?
    else
      @set = {}
    end
  end
  
  def availability
    if params[:availability_form]
      @set = params[:availability_form]
      
      @unavailable = false
      @unavailable = true if params[:availability_form][:request_unav].to_i == 1
      
      validator = AvailabilityValidator.new(params[:availability_form])
      
      handle_user_action(validator, params[:user_action]) if params[:user_action].present?
    else
      @set = {}
    end
  end
  
  def calculate
    if params[:calculate_form]
      @set = params[:calculate_form]
      
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
      @set = {}
      @billing = 1
      @billing_index = ["0"]
      @billing_array = [["","",""]]
    end
  end
  
  def res_hold
    if params[:res_hold_form]
      @set = params[:res_hold_form]
      
      @cust = params[:res_hold_form][:customer]
      @cust[:terms_accept] = string_to_boolean @cust[:terms_accept]

      if params[:user_action] == "Update"
        @billing = 1
        @billing = params[:res_hold_form][:bill_num].to_i if params[:res_hold_form][:bill_num].to_i > 0
        update_billing_array(params[:res_hold_form])
      else
        @billing = params[:res_hold_form][:current_bill_num].to_i
        update_billing_array(params[:res_hold_form])
        
        validator = ResHoldValidator.new(params[:res_hold_form])
        
        handle_user_action(validator, params[:user_action])
      end
    else
      @set = {site: {}, unit: {}, date: {}, site_choice: {} }
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
