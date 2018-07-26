require 'builder'
require 'rexml/document'

class ServicesController < ApplicationController
  def utility
    page_generation
  end
  
  def availability
    page_generation
  end
  
  def calculate
    page_generation
  end
  
  def res_hold
    page_generation
  end
  
  def res_confirm
    page_generation
  end
  
  def site_usage
    page_generation
  end
  
  def res_create
    page_generation
  end
  
  def site_cancel
    page_generation
  end
  
  def res_reverse
    page_generation
  end
  
  def page_generation
    @output = {}
    
    if params[:input_form]
      @set = params[:input_form]

      if params[:input_form][:customer].present?
        @cust = params[:input_form][:customer]
        @cust[:terms_accept] = string_to_boolean @cust[:terms_accept]
      end

      if params[:input_form][:request_unav].present?
        @unavailable = false
        @unavailable = true if params[:input_form][:request_unav].to_i == 1
      end

      if params[:input_form][:billing].present?
        if params[:user_action] == 'Update'
          @billing = 1
          @billing = params[:input_form][:bill_num].to_i if params[:input_form][:bill_num].to_i > 0
          update_billing_array(params[:input_form][:billing])
        else
          @billing = params[:input_form][:billing][:current_bill_num].to_i
          update_billing_array(params[:input_form][:billing])
        end
      end

      if params[:user_action].present? && params[:user_action] != 'Update'
        validator = generate_validator(params[:input_form])

        handle_user_action(validator, params[:user_action])
      end
    else
      @set = { date: {}, unit: {}, site: {}, site_choice: {} }
      @set[:site_choice] = { site1: {}, site2: {}, site3: {} } if params[:action] == "site_usage"
      @billing = 1
      @billing_index = ["0"]
      @billing_array = [["","",""]]
      @cust = { }
    end
  end # - page_generation
  
  def generate_validator(inputs)
    case params[:action]
    when "availability" then AvailabilityValidator.new(inputs)
    when "calculate" then CalculateValidator.new(inputs)
    when "res_confirm" then ResConfirmValidator.new(inputs)
    when "res_create" then ResCreateValidator.new(inputs)
    when "res_hold" then ResHoldValidator.new(inputs)
    when "res_reverse" then ResReverseValidator.new(inputs)
    when "site_cancel" then SiteCancelValidator.new(inputs)
    when "site_usage" then SiteUsageValidator.new(inputs)
    when "utility" then UtilityValidator.new(inputs)  
    else nil
    end
  end
  
  def handle_user_action(validator, user_action)
    if validator.present?
      if validator.valid? || user_action == "Force Submit"
        validator.resolve_action(user_action)
        @output = validator.output
      else
        @output = { request_errors: validator.errors }
      end
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
