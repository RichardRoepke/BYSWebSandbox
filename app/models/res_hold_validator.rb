class ResHoldValidator < CalculateValidator
  include ActiveModel::Validations

  attr_accessor :reservation_ID
  attr_accessor :rate_ID
  attr_accessor :member_UUID
  attr_accessor :site_choice
  attr_accessor :loyalty_code
  attr_accessor :loyalty_text
  attr_accessor :discount_code
  attr_accessor :discount_text

  validates :reservation_ID, presence: { message: 'Reservation Request ID must be present' }
  validates :rate_ID, presence: { message: 'Rate Calcuation ID must be present' }
  validates :member_UUID, format: { with: /\A[0-9]*\z/, message: 'Member UUID only accepts numbers if present.' }

  validate  :valid_unit
  validate  :valid_customer
  validate  :valid_billing
  validate  :loyalty_program
  validate  :discount

  def initialize(form)
    @site = SiteValidator.new( form[:site] )
    @unit = UnitValidator.new( form[:unit] )
    @date = DateValidator.new( form[:date] )
    @customer = CustomerValidator.new( form[:customer] )
    @billing = BillingArrayValidator.new( form[:billing] )

    @request_ID = 'ReservationHoldRequest'
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @version_num = form[:version_num].to_s
    @reservation_ID = form[:reservation_ID].to_s
    @rate_ID = form[:rate_ID].to_s
    @member_UUID = form[:member_UUID].to_s
    @site_choice = form[:site_choice]
    @loyalty_code = form[:loyalty_code].to_s
    @loyalty_text = form[:loyalty_text].to_s
    @discount_code = form[:discount_code].to_s
    @discount_text = form[:discount_text].to_s

    @output = Hash.new
  end

  def valid_customer
    objectvalidation(@customer, '')
  end

  def valid_unit
    objectvalidation(@unit, 'Unit ')
  end

  def valid_billing
    objectvalidation(@billing, '')
  end

  def loyalty_program
    if @loyalty_code != '' && @loyalty_text != ''
      return true
    elsif @loyalty_code == '' && @loyalty_text == ''
      return true
    else
      errors.add(:base, 'Loyalty Code and Loyalty Text must both be present or neither be present.')
      return false
    end
  end

  def discount
    if @discount_code != '' && @discount_text != ''
      return true
    elsif @discount_code == '' && @discount_text == ''
      return true
    else
      errors.add(:base, 'Discount Code and Discount Text must both be present or neither be present.')
      return false
    end
  end

  def generate_path
    'https://54.197.134.112:3400/reservationhold'
  end

  def build_XML
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!('Envelope', 'xmlns:xsi'=>'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation'=>'/home/bys/Desktop/SHARE/xml2/ReservationHoldRequest/reservationHoldRequest.xsd')  {
      xml.tag!('Body') {
        xml.tag!('reservationhold'){
          xml.tag!('RequestData'){
            xml.tag!('RequestIdentification'){
              xml.ServiceRequestID 'ReservationHoldRequest'
              xml.ServiceRequestVersion @version_num
              xml.tag!('CampGroundIdentification'){
                xml.CampGroundUserName @park_ID
                xml.CampGroundSecurityKey @security_key
              }
            }

            xml.tag!('ReservationHoldRequest') {
              xml.ReservationRequestID @reservation_ID

              xml.SiteTypeInternalUID @site.internal_UID unless @site.internal_UID == ''
              xml.SiteTypeID @site.type_ID unless @site.type_ID == ''

              xml.UnitTypeInternalUID @unit.internal_UID unless @unit.internal_UID == ''
              xml.UnitType @unit.type_ID unless @unit.type_ID == ''
              xml.UnitLength @unit.length unless @unit.length == ''

              xml.ArrivalDate @date.arrival_date
              xml.NumberOfNights @date.num_nights

              xml.FirstName @customer.first_name
              xml.LastName @customer.last_name
              xml.Email @customer.email
              xml.PrimaryPhone @customer.phone

              if @customer.phone_alt != ''
                xml.AlternatePhone @customer.phone_alt
              else
                xml.AlternatePhone
              end

              xml.Address1 @customer.address_one
              xml.Address2 @customer.address_two
              xml.City @customer.city
              xml.StateProvince @customer.state_province
              xml.ZipPostalCode @customer.postal_code
              xml.NoteToPark @customer.note unless @customer.note == ''
              xml.TermsConditionsAccepted @customer.terms_accept

              xml.RateCalculationID @rate_ID
              xml.MemberUUID @member_UUID unless @member_UUID == ''

              xml.tag!('SiteSelection') {
                @site_choice.each do |id, site|
                  xml.SiteName site.to_s unless site.to_s == ''
                end
              } unless no_site_choice?

              xml.tag!('Loyalty') {
                xml.LoyaltyCode @loyalty_code
                xml.LoyaltyText @loyalty_text
              } unless @loyalty_text == '' # We already know that the code matches so no need to check both.

              xml.tag!('BillingDetails'){
                @billing.billing_array.each do |bill|
                  xml.tag!('BillingDetail'){
                    xml.BillingItem bill.item.to_s
                    xml.BillingItemType bill.type.to_s
                    xml.BillingQty bill.quantity.to_s
                  }
                end
              }

              xml.tag!('Discount') {
                xml.DiscountCode @discount_code
                xml.DiscountText @discount_text
              } unless @discount_text == '' # We already know that the code matches so no need to check both.

              xml.tag!('CCInfo') {
                xml.CCType @customer.cc_type
                xml.CCExpiry @customer.cc_expiry
                xml.CC_Enc @customer.cc_number
              }
            }
          }
        }
      }
    }
  end # - build_XML

  def no_site_choice?
    result = true

    @site_choice.each do |id, site|
      result = false unless site.to_s == ''
    end

    return result
  end
end
