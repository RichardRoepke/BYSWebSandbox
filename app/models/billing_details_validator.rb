class AvailabilityValidator < ServiceValidator
  include ActiveModel::Validations
  
  attr_accessor :billing_item
  attr_accessor :item_type
  attr_accessor :item_quantity
  
  validates :billing_item, presence: { message: "Billing Item is required" }
  validates :item_type, format: { with: /\A(0|1)\z/, message: "Billing Item Type must be 0 or 1."}
  validates :item_quantity, format: { with: /\A[0-9]*\z/, message: "Billing Item Quantity must be a number."}
  
  validate  :type_quantity_match
  
  def initialize(form)
    @billing_item = form[:billing_item].to_s
    @item_type = form[:item_type].to_s
    @item_quantity = form[:item_quantity].to_s
  end
end