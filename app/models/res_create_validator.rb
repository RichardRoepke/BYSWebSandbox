class ResCreateValidator < ServiceValidator

  attr_accessor :usage_token

  validates :usage_token, presence: { message: 'Site Usage Hold Token must be present.' }

  validate  :valid_customer
  validate  :valid_billing

  def initialize(form)
    @customer = CustomerValidator.new( form[:customer] )

    @request_ID = 'ReservationCreateRequest'
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @version_num = form[:version_num].to_s
    @usage_token = form[:usage_token].to_s
    @billing = BillingArrayValidator.new( form[:billing] )

    @output = Hash.new
  end

  def valid_customer
    objectvalidation(@customer, '')
  end

  def valid_billing
    objectvalidation(@billing, '')
  end

  def generate_path
    'https://54.197.134.112:3400/reservationcreate'
  end

  def build_XML
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!('Envelope', 'xmlns:xsi'=>'http://www.w3.org/2001/XMLSchema-instance',
                         'xsi:noNamespaceSchemaLocation'=>'/home/bys/Desktop/SHARE/xml2/ReservationCreateRequest/reservationCreateRequest.xsd')  {
      xml.tag!('Body') {
        xml.tag!('reservationcreate'){
          xml.tag!('RequestData'){
            xml.tag!('RequestIdentification'){
              xml.ServiceRequestID 'ReservationCreateRequest'
              xml.ServiceRequestVersion @version_num if @version_num.present?
              xml.tag!('CampGroundIdentification'){
                xml.CampGroundUserName @park_ID
                xml.CampGroundSecurityKey @security_key
              }
            }

            xml.tag!('ReservationCreateRequest') {
              xml.SiteUsageHoldToken @usage_token

              xml.tag!('BillingDetails'){
                @billing.billing_array.each do |bill|
                  xml.tag!('BillingDetail'){
                    xml.BillingItem bill.item.to_s
                    xml.BillingItemType bill.type.to_s
                    xml.BillingQty bill.quantity.to_s
                  }
                end
              }

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

              xml.tag!('CCInfo') {
                xml.CCType @customer.cc_type
                xml.CCExpiry @customer.cc_expiry
                xml.CCNumber @customer.cc_number
              }

              xml.NoteToPark @customer.note unless @customer.note == ''
              xml.TermsConditionsAccepted @customer.terms_accept
            }
          }
        }
      }
    }
  end # - build_XML
end
