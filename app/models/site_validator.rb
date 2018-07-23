class SiteValidator
  include ActiveModel::Validations
  
  attr_accessor :internal_UID
  attr_accessor :type_ID
  
  validates :internal_UID, format: { with: /\A\-*[0-9]*\z/, message: "Internal UID must be a number."}
  validates :type_ID, format: { with: /\A^[a-zA-Z0-9_\-\\]*\z/, message: "Type ID can only be alphanumeric characters, dashes, underscores and backslashes."}
  
  validate  :UID_or_ID
  validate  :UID_value
  
  def initialize(form)
    @internal_UID = form[:internal_UID].to_s
    @type_ID = form[:type_ID].to_s
  end
  
  def UID_value
    unless @internal_UID == ""
      if @internal_UID.to_i > 0
        return true
      else
        errors.add(:base, "Internal UID must be greater than 0 if present.")
        return false
      end
    end
    
    return true
  end
  
  def UID_or_ID
    if @internal_UID == "" && @type_ID == ""
      errors.add(:base, "At least one of Internal UID or ID must be present.")
      return false
    else
      return true
    end
  end
end