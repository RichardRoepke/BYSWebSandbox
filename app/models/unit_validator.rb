class UnitValidator < SiteValidator
  include ActiveModel::Validations
  
  attr_accessor :length

  validates :length, format: { with: /\A\-*[0-9]*\z/, message: "Length must be a number."}

  validate  :length_range
  
  def initialize(form)
    @internal_UID = form[:internal_UID].to_s
    @type_ID = form[:type_ID].to_s
    @length = form[:length].to_s
  end

  def length_range
    unless @length == ""
      if @length.to_i < 1 || @length.to_i > 100
        errors.add(:base, "Length must be between 1 and 100 if present.")
        return false
      else
        return true
      end
    end
    
    return true
  end
end