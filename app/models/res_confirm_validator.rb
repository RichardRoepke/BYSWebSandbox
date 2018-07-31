class ResConfirmValidator < ServiceValidator
  attr_accessor :reservation_ID
  attr_accessor :hold_token
  attr_accessor :action

  validates :reservation_ID, presence: { message: 'Reservation Request ID must be present' }
  validates :hold_token, presence: { message: 'Reservation Hold Token must be present' }
  validates :action, format: { with: /\A(CONFIRM|CANCEL)\z/, message: 'Action must be CONFIRM or CANCEL.' }

  def initialize(form)
    @request_ID = 'ReservationConfirmRequest'
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @reservation_ID = form[:reservation_ID].to_s
    @hold_token = form[:hold_token].to_s
    @action = form[:action].to_s

    @output = Hash.new
  end

  def generate_path
    'https://54.197.134.112:3400/reservationconfirm'
  end

  def build_XML
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!('Envelope', 'xmlns:xsi'=>'http://www.w3.org/2001/XMLSchema-instance',
                         'xsi:noNamespaceSchemaLocation'=>'/home/bys/Desktop/SHARE/xml2/ReservationConfirmRequest/reservationConfirmRequest.xsd')  {
      xml.tag!('Body') {
        xml.tag!('reservationconfirm'){
          xml.tag!('RequestData'){
            xml.tag!('RequestIdentification'){
              xml.ServiceRequestID 'ReservationConfirmRequest'
              xml.tag!('CampGroundIdentification'){
                xml.CampGroundUserName @park_ID
                xml.CampGroundSecurityKey @security_key
              }
            }

            xml.tag!('ReservationConfirmRequest') {
              xml.ReservationRequestID @reservation_ID
              xml.ReservationHoldToken @hold_token
              xml.Action @action
            }
          }
        }
      }
    }
  end # - build_XML
end
