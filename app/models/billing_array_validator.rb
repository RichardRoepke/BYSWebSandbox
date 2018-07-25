class BillingArrayValidator
  include ActiveModel::Validations
  
  attr_accessor :billing_array
  
  validate  :valid_billing
  
  def initialize(form)
    @billing_array = []
    
    form[:current_bill_num].to_i.times do |n|
      @billing_array.push(BillingValidator.new(form[n.to_s.to_sym]))
    end
  end
  
  def valid_billing
    result = true
    num = 1
    
    @billing_array.each do |bill|
      unless bill.valid?
        result = false
        bill.errors.each do |type, message|
          errors.add(:base, "Billing Item " + num.to_s + ": " + message)
        end
      end
      
      num += 1
    end
    
    return result
  end
end