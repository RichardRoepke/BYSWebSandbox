require 'test_helper'

class UtilityValidatorTest < ActiveSupport::TestCase
  def setup
    form = { request_ID: 'UnitTypeInfoRequest',
             park_ID: 'M00000',
             security_key: 'yes' }
    @utility = UtilityValidator.new(form)
  end

  test 'xsd_path should generate proper responses' do
    @utility.request_ID = 'UnitTypeInfoRequest'
    assert_equal @utility.XSD_path, 'unitTypeInfoRequest'
    @utility.request_ID = 'SiteTypeInfoRequest'
    assert_equal @utility.XSD_path, 'siteTypeInfoRequest'
    @utility.request_ID = 'NotesAndTermsRequest'
    assert_equal @utility.XSD_path, 'NotesAndTermsRequest'
    @utility.request_ID = 'BYSPublicKeyRequest'
    assert_equal @utility.XSD_path, 'BYSPublicKeyRequest'
  end

  test 'generate_path should generate proper ID addresses' do
    @utility.request_ID = 'UnitTypeInfoRequest'
    assert_equal @utility.generate_path, 'https://54.197.134.112:3400/unittypeinfo'
    @utility.request_ID = 'SiteTypeInfoRequest'
    assert_equal @utility.generate_path, 'https://54.197.134.112:3400/sitetypeinfo'
    @utility.request_ID = 'NotesAndTermsRequest'
    assert_equal @utility.generate_path, 'https://54.197.134.112:3400/notesandterms'
    @utility.request_ID = 'BYSPublicKeyRequest'
    assert_equal @utility.generate_path, 'https://54.197.134.112:3400/byspublickey'
  end
end
