class BillingValidator
  include ActiveModel::Validations
  
  attr_accessor :item
  attr_accessor :type
  attr_accessor :quantity
  
  validates :item, presence: { message: "Billing item is required." }
  validates :type, format: { with: /\A(0|1)\z/, message: "Billing Type must be 0 or 1."}
  validates :quantity, format: { with: /\A-*[0-9]*\z/, message: "Billing Quantity must be a number" }
  
  validate  :type_quantity_match
  
  def initialize(form)
    @item = form[:item].to_s
    @type = form[:type].to_s
    @quantity = form[:quantity].to_s
  end
  
  def type_quantity_match
    if @type == "0"
      if @quantity.to_i >= 0
        return true
      else
        errors.add(:base, "Billing Quantity must be 0 or greater if Billing Type is numeric.")
        return false
      end
    elsif @type == "1"
      if @quantity == "0" || @quantity == "1"
        return true
      else
        errors.add(:base, "Billing Quantity must be 0 or 1 if Billing Type is boolean.")
        return false
      end
    end
  end
end