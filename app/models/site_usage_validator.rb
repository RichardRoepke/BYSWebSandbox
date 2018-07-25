class SiteUsageValidator < ServiceValidator
  include ActiveModel::Validations

  attr_accessor :usage_ID

  validates :usage_ID, presence: { message: 'Usage Hold ID must be present' }

  validate  :valid_date
  validate  :valid_unit
  validate  :valid_site_type
  validate  :valid_site_list

  def initialize(form)
    @request_ID = 'SiteUsageHoldRequest'
    @park_ID = form[:park_ID].to_s
    @security_key = form[:security_key].to_s
    @usage_ID = form[:usage_ID].to_s

    @unit = UnitValidator.new( form[:unit] )
    @date = DateValidator.new( form[:date] )
    @site = SiteValidator.new( form[:site] )

    @site_list = {}

    form[:site_choice].each do |name, site|
      if site.present?
        if site[:type_ID] != '' || site[:internal_UID] != ''
          @site_list[name.to_sym] = SiteValidator.new(site)
        end
      end
    end

    @output = Hash.new
  end

  def valid_unit
    objectvalidation(@unit, 'Unit ')
  end

  def valid_date
    objectvalidation(@date, '')
  end

  def valid_site_type
    objectvalidation(@site, 'Site ')
  end

  def valid_site_list
    result = true

    @site_list.each do |name, choice|
      unless choice.valid?
        choice.errors.each do |type, message|
          errors.add(:base, 'Site Choice #' + name.to_s + ': ' + message)
        end
        result = false
      end
    end

    return result
  end

  def generate_path
    'https://54.197.134.112:3400/siteusagehold'
  end

  def build_XML
    xml = Builder::XmlMarkup.new(:indent=>2)
    xml.instruct! :xml, :version=>'1.0' #:content_type=>'text/xml' #, :encoding=>'UTF-8'
    xml.tag!('Envelope', 'xmlns:xsi'=>'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation'=>'/home/bys/Desktop/SHARE/xml2/SiteUsageHoldRequest/siteUsageHoldRequest.xsd')  {
      xml.tag!('Body') {
        xml.tag!('siteusagehold'){
          xml.tag!('RequestData'){
            xml.tag!('RequestIdentification'){
              xml.ServiceRequestID 'SiteUsageHoldRequest'
              xml.tag!('CampGroundIdentification'){
                xml.CampGroundUserName @park_ID
                xml.CampGroundSecurityKey @security_key
              }
            }

            xml.tag!('SiteUsageHoldRequest') {
              xml.UsageRequestID @usage_ID
              xml.ArrivalDate @date.arrival_date
              xml.NumberOfNights @date.num_nights

              xml.tag!('SiteType'){
                xml.SiteTypeInternalUID @site.internal_UID unless @site.internal_UID == ''
                xml.SiteType @site.type_ID unless @site.type_ID == ''
              }

              xml.tag!('UnitType'){
                xml.UnitTypeInternalUID @unit.internal_UID unless @unit.internal_UID == ''
                xml.UnitType @unit.type_ID unless @unit.type_ID == ''
                xml.UnitLength @unit.length unless @unit.length == ''
              }

              xml.tag!('SiteList'){
                @site_list.each do |type, choice|
                  xml.tag!('Site'){
                    xml.SiteInternalUID choice.internal_UID unless choice.internal_UID == ''
                    xml.SiteID choice.type_ID unless choice.type_ID == ''
                  }
                end
              } unless @site_list.empty?
            }
          }
        }
      }
    }
  end # - build_XML
end
