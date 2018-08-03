class SiteCancelValidator < ServiceValidator

  attr_accessor :usage_token

  validates :usage_token, presence: { message: 'Site Usage Hold Token is required' }

  def initialize(form)
    @request_ID = 'SiteUsageCancelRequest'
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @version_num = form[:version_num].to_s
    @usage_token = form[:usage_token].to_s

    @output = Hash.new
  end

  def generate_path
    'https://54.197.134.112:3400/siteusagecancel'
  end

  def build_XML()
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!('Envelope', 'xmlns:xsi'=>'http://www.w3.org/2001/XMLSchema-instance',
                         'xsi:noNamespaceSchemaLocation'=>'file:/home/bys/Desktop/SHARE/xml2/SiteUsageCancelRequest/siteUsageCancelRequest.xsd')  {
      xml.tag!('Body') {
        xml.tag!('siteusagecancel'){
          xml.tag!('RequestData'){
            xml.tag!('RequestIdentification'){
              xml.ServiceRequestID 'SiteUsageCancelRequest'
              xml.ServiceRequestVersion @version_num if @version_num.present?
              xml.tag!('CampGroundIdentification'){
                xml.CampGroundUserName @park_ID.to_s
                xml.CampGroundSecurityKey @security_key.to_s
              }
            }

            xml.tag!('SiteUsageCancelRequest'){
              xml.SiteUsageHoldToken @usage_token.to_s
            }
          }
        }
      }
    }
  end # - build_XML
end
