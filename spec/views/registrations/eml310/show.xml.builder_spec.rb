require 'spec_helper'

describe "registrations/eml310/show", formats: [ :xml ], handlers: [ :builder ] do

  describe 'general' do
    before { reg }

    it 'should render the header' do
      xml.within 'EML EMLHeader' do |x|
        x.should have_selector 'TransactionId', text: '310'
        x.within 'OfficialStatusDetail' do |d|
          d.should have_selector 'OfficialStatus', text: 'submitted'
          d.should have_selector 'StatusDate', text: Date.today.strftime("%Y-%m-%d")
        end
      end
    end

    it 'should render the source' do
      xml.within 'EML VoterRegistration Voter Source' do |s|
        s.should have_selector 'Name', text: AppConfig['xml']['source_name']
        s.should have_selector 'IdValue', text: '806000539'
      end
    end
  end

  describe 'voter name' do
    it 'should output minimal version' do
      reg first_name: 'FN', middle_name: nil, last_name: 'LN', suffix: nil
      xml.within 'EML VoterRegistration Voter VoterIdentification VoterName' do |n|
        n.should have_selector 'GivenName',       text: 'FN'
        n.should have_selector 'MiddleName',      text: ''
        n.should have_selector 'FamilyName',      text: 'LN'
        n.should have_selector 'NameSuffixText',  text: ''
      end
    end

    it 'should output maximal version' do
      reg first_name: 'FN', middle_name: 'MN', last_name: 'LN', suffix: 'S'
      xml.within 'EML VoterRegistration Voter VoterIdentification VoterName' do |n|
        n.should have_selector 'GivenName',       text: 'FN'
        n.should have_selector 'MiddleName',      text: 'MN'
        n.should have_selector 'FamilyName',      text: 'LN'
        n.should have_selector 'NameSuffixText',  text: 'S'
      end
    end
  end

  describe 'electoral address' do
    it 'should render rural address' do
      reg vvr_is_rural: '1', vvr_rural: 'Rural address'
      xml.within 'EML VoterRegistration Voter VoterIdentification' do |x|
        x.within "ElectoralAddress[type='Rural'][status='current'] FreeTextAddress" do |a|
          a.should have_selector 'AddressLine', text: 'Rural address'
        end
      end
    end

    it 'should render local address' do
      reg vvr_street_number: '1', vvr_street_name: 'SN', vvr_street_type: 'AVE', vvr_apt: '2', vvr_county_or_city: 'BRISTOL CITY', vvr_town: 'BRISTOL', vvr_state: 'VA', vvr_zip5: '12345', vvr_zip4: '6789'
      xml.within "ElectoralAddress[status='current']:not([type='Rural']) PostalAddress" do |a|
        a.should have_selector "Thoroughfare[type='AVE'][number='1'][name='SN']", text: "1 SN AVE"
        a.should have_selector "OtherDetail", text: '2'
        a.should have_selector "Locality[type='Town']", text: 'BRISTOL'
        a.should have_selector "AdministrativeArea[type='StateCode']", text: 'VA'
        a.should have_selector "PostCode[type='ZipCode']", text: '123456789'
        a.should have_selector "Country[code='USA']", text: 'United States of America'
      end
    end
  end

  describe 'mailing address' do
    context 'residential' do
      it 'is the same as registration' do
        r = reg ma_is_different: '0', vvr_zip5: 12345, vvr_zip4: nil, vvr_apt: nil
        xml.within "VoterInformation Contact MailingAddress[status='current'] PostalAddress" do |a|
          a.should have_selector "Thoroughfare[type='#{r.vvr_street_type}'][number='#{r.vvr_street_number}'][name='#{r.vvr_street_name}']", text: "#{r.vvr_street_number} #{r.vvr_street_name} #{r.vvr_street_type}"
          a.should have_selector "Locality[type='Town']", text: r.vvr_town
          a.should have_selector "AdministrativeArea[type='StateCode']", text: r.vvr_state
          a.should have_selector "PostCode[type='ZipCode']", text: '12345'
          a.should have_selector "Country[code='USA']", text: 'United States of America'
          a.should_not have_selector "OtherDetail"
        end
      end

      it 'is different from registration' do
        r = reg ma_is_different: '1', ma_address: '518 Vance ST', ma_address_2: 'Apt 12', ma_city: 'C', ma_state: 'MA', ma_zip5: '11111', ma_zip4: '2222'
        xml.within "MailingAddress[status='current'] FreeTextAddress" do |a|
          a.should have_selector "AddressLine[seqn='0001'][type='MailingAddressLine1']", text: "518 Vance ST"
          a.should have_selector "AddressLine[seqn='0002'][type='MailingAddressLine2']", text: "Apt 12"
          a.should have_selector "AddressLine[seqn='0003'][type='MailingCity']", text: 'C'
          a.should have_selector "AddressLine[seqn='0004'][type='MailingState']", text: 'MA'
          a.should have_selector "AddressLine[seqn='0005'][type='MailingZip']", text: '111112222'
        end
      end
    end

    context 'overseas' do
      it 'is non-US' do
        r = reg_overseas mau_type: 'non-us', mau_address: 'a1', mau_address_2: 'a2', mau_city: 'c', mau_city_2: 'c2', mau_state: 's', mau_postal_code: '12345', mau_country: 'country'
        xml.within "MailingAddress[status='current'] FreeTextAddress" do |a|
          a.should have_selector "AddressLine[seqn='0001']:not([type])", text: 'a1'
          a.should have_selector "AddressLine[seqn='0002']:not([type])", text: 'a2'
          a.should have_selector "AddressLine[seqn='0003'][type='City']", text: 'c c2'
          a.should have_selector "AddressLine[seqn='0004'][type='State']", text: 's'
          a.should have_selector "AddressLine[seqn='0005'][type='PostalCode']", text: '12345'
          a.should have_selector "AddressLine[seqn='0006'][type='Country']", text: 'country'
        end
      end

      it 'is APO/DPO/FPO' do
        r = reg_overseas mau_type: 'apo', apo_address: 'a1', apo_address_2: 'a2', apo_city: '1', apo_state: '2', apo_zip5: '12345'
        xml.within "MailingAddress[status='current'] FreeTextAddress" do |a|
          a.should have_selector "AddressLine[seqn='0001']:not([type])", text: 'a1'
          a.should have_selector "AddressLine[seqn='0002']:not([type])", text: 'a2'
          a.should have_selector "AddressLine[seqn='0003'][type='City']", text: '1'
          a.should have_selector "AddressLine[seqn='0004'][type='State']", text: '2'
          a.should have_selector "AddressLine[seqn='0005'][type='PostalCode']", text: '12345'
          a.should have_selector "AddressLine[seqn='0006'][type='Country']", text: 'United States'
        end
      end
    end
  end

  describe 'previous registration' do
    it 'should not render when none' do
      reg
      xml.should_not have_selector "PreviousElectoralAddress"
    end

    it 'should render non-rural' do
      reg pr_status: '1',
          pr_address: 'Line 1', pr_address_2: 'Line 2',
          pr_city: 'C', pr_state: 'VA', pr_zip5: '54321', pr_zip4: '6789'

      xml.within "PreviousElectoralAddress[status='previous'] PostalAddress" do |a|
        pending "update checks when the format settles down"
        # a.should have_selector "Thoroughfare[type='ST'][name='SN'][number='1']", text: "1 SN ST"
        # a.should have_selector "Locality[type='Town']", text: 'C'
        # a.should have_selector "AdministrativeArea[type='StateCode']", text: 'VA'
        # a.should have_selector "PostCode[type='ZipCode']", text: '543216789'
        # a.should have_selector "Country[code='USA']", text: 'United States of America'
      end
    end

    it 'should render rural' do
      reg pr_status: '1',
        pr_is_rural: '1', pr_rural: 'Rural address'

      xml.within "PreviousElectoralAddress[status='previous'][type='Rural']" do |a|
        a.should have_selector "FreeTextAddress AddressLine", text: 'Rural address'
      end
    end
  end

  describe 'identification' do
    it 'should render SSN if present' do
      reg ssn: '123123123'
      xml.should have_selector "VoterIdentification VoterPhysicalID[IdType='SSN']", text: '123123123'
    end

    it 'should not render SSN when missing' do
      reg
      xml.should_not have_selector "VoterIdentification VoterPhysicalID"
    end
  end

  describe 'voter informaton' do
    it 'should not render email / phone if none' do
      reg email: nil, phone: nil
      xml.should_not have_selector "Email"
      xml.should_not have_selector "Telephone"
    end

    it 'should render email and phone' do
      reg email: 'john@smith.com', phone: '1234567890'
      xml.should have_selector "VoterInformation Contact Email", text: 'john@smith.com'
      xml.should have_selector "VoterInformation Contact Telephone Number", text: '1234567890'
    end
  end

  describe 'voter general' do
    it 'should render DOB' do
      reg
      xml.should have_selector "VoterInformation DateOfBirth", text: '1950-11-06'
    end

    it 'should render gender' do
      reg gender: 'Male'
      xml.should have_selector "VoterInformation Gender", text: 'male'
    end

    it 'should render eligibility flags' do
      reg
      xml.should have_selector "VoterInformation CheckBox[Type='Eighteenplus']", text: 'yes'
      xml.should have_selector "VoterInformation CheckBox[Type='Citizen']", text: 'yes'
      xml.should have_selector "VoterInformation CheckBox[Type='RegistrationStatement']", text: 'yes'
      xml.should have_selector "VoterInformation CheckBox[Type='PrivacyNotice']", text: 'yes'
    end

    it 'should render residence still available for domestic voter' do
      reg
      xml.should have_selector "VoterInformation CheckBox[Type='ResidenceStillAvailable']", text: 'yes'
    end

    it 'should render residence still available for overseas voter' do
      reg_overseas vvr_uocava_residence_available: '1'
      xml.should have_selector "VoterInformation CheckBox[Type='ResidenceStillAvailable']", text: 'yes'
    end

    it 'should render residence unavailble for overseas voter' do
      reg_overseas vvr_uocava_residence_available: '0', vvr_uocava_residence_unavailable_since: Kronic.parse('June 1, 2000')
      xml.should have_selector "VoterInformation CheckBox[Type='ResidenceStillAvailable']", text: 'no'
      xml.should have_selector "FurtherInformation Message[Type='DateofLastResidence'][DisplayOrder][Seqn]", text: '2000-06-01'
    end

    it 'should render election official flag' do
      reg be_official: '1'
      xml.should have_selector "VoterInformation CheckBox[Type='ElectionOfficialInterest']", text: 'yes'
    end

    describe 'rights' do
      it 'should render when not revoked' do
        reg rights_revoked: '0'
        xml.should have_selector "VoterInformation CheckBox[Type='VotingRightsRevoked']", text: 'no'
        xml.should_not have_selector "VoterInformation FurtherInformation Message[Type='Felony']"
        xml.should_not have_selector "VoterInformation FurtherInformation Message[Type='Incapacitated']"
      end

      it 'should render when felony and restored' do
        reg rights_revoked: '1', rights_revoked_reason: 'felony', rights_restored_in: 'MA', rights_restored_on: Kronic.parse('10 Dec, 2000'), rights_restored: '1'
        xml.should have_selector "VoterInformation CheckBox[Type='VotingRightsRevoked']", text: 'yes'
        xml.within "FurtherInformation Message[DisplayOrder='0001'][Type='Felony'][Seqn='1']" do |f|
          f.should have_selector "Felony[RightsRestored='yes'][ConvictionState='MA'][RestoredDate='2000-12-10']", text: 'yes'
        end
      end

      it 'should render when mental and restored' do
        reg rights_revoked: '1', rights_revoked_reason: 'mental', rights_restored_on: Kronic.parse('10 Dec, 2000'), rights_restored: '1'
        xml.should have_selector "VoterInformation CheckBox[Type='VotingRightsRevoked']", text: 'yes'
        xml.within "FurtherInformation Message[DisplayOrder='0001'][Type='Incapacitated'][Seqn='1']" do |f|
          f.should have_selector "Incapacitated[RightsRestored='yes'][RestoredDate='2000-12-10']", text: 'yes'
        end
      end

      it 'should render when felony and not restored' do
        reg rights_revoked: '1', rights_revoked_reason: 'felony'
        xml.should have_selector "VoterInformation CheckBox[Type='VotingRightsRevoked']", text: 'yes'
        xml.within "FurtherInformation Message[DisplayOrder='0001'][Type='Felony'][Seqn='1']" do |f|
          f.should have_selector "Felony[RightsRestored='no']", text: 'yes'
        end
      end

      it 'should render when mental and not restored' do
        reg rights_revoked: '1', rights_revoked_reason: 'mental'
        xml.should have_selector "VoterInformation CheckBox[Type='VotingRightsRevoked']", text: 'yes'
        xml.within "FurtherInformation Message[DisplayOrder='0001'][Type='Incapacitated'][Seqn='1']" do |f|
          f.should have_selector "Incapacitated[RightsRestored='no']", text: 'yes'
        end
      end
    end

    describe 'absentee fields' do
      it 'should not render absentee fields' do
        reg requesting_absentee: '0'
        xml.should have_selector "VoterInformation CheckBox[Type='AbsenteeRequest']", text: 'no'
        xml.should_not have_selector "Message[Type='AbsenteeRequest']"
      end

      it 'should render absentee fields for known election' do
        reg_absentee rab_election: 'Election Name'

        xml.should have_selector "VoterInformation CheckBox[Type='AbsenteeRequest']", text: 'yes'
        xml.within "Message[Type='AbsenteeRequest']" do |a|
          a.should have_selector "AbsenteeType", text: 'Student'
          a.should have_selector "AbsenteeInfo", text: 'Election Name / 3 sn LN, apt, c MA 333335555, co / fld1 / fld2 / 00:00 - 23:00'
        end
      end

      it 'should render absentee fields for custom election' do
        reg_absentee rab_election_name: 'name', rab_election_date: '12/10/2013'

        xml.within "Message[Type='AbsenteeRequest']" do |a|
          a.should have_selector "AbsenteeInfo", text: 'name on 12/10/2013 / 3 sn LN, apt, c MA 333335555, co / fld1 / fld2 / 00:00 - 23:00'
        end
      end

      it 'should render military details' do
        reg_overseas requesting_absentee: '1',
          outside_type: 'ActiveDutyMerchantMarineOrArmedForces',
          service_branch: 'Army', service_id: 'sid', rank: 'rank'
        xml.should have_selector "VoterInformation CheckBox[Type='Military']", text: 'yes'
        xml.should have_selector "VoterInformation CheckBox[Type='Overseas']", text: 'no'
        xml.should have_selector "VoterInformation CheckBox[Type='AbsenteeRequest']", text: 'yes'
        xml.within "Message[Type='AbsenteeRequest']" do |a|
          a.should have_selector "AbsenteeType", text: 'ActiveDutyMerchantMarineOrArmedForces'
          a.should have_selector "AbsenteeInfo", text: 'Army sid rank'
        end
      end

      it 'should render overseas details' do
        reg_overseas requesting_absentee: '1', outside_type: 'TemporaryResideOutside'
        xml.should have_selector "VoterInformation CheckBox[Type='Military']", text: 'no'
        xml.should have_selector "VoterInformation CheckBox[Type='Overseas']", text: 'yes'
        xml.should have_selector "VoterInformation CheckBox[Type='AbsenteeRequest']", text: 'yes'
        xml.within "Message[Type='AbsenteeRequest']" do |a|
          a.should have_selector "AbsenteeType", text: 'TemporaryResideOutside'
          a.should have_selector "AbsenteeInfo", text: ''
        end
      end
    end

    describe 'ACP fields' do
      it 'should not render ACP fields' do
        reg is_confidential_address: '0'
        xml.should have_selector "VoterInformation CheckBox[Type='AddressConfidentialityRequest']", text: 'no'
        xml.should_not have_selector "Message[Type='Confidential']"
      end

      it 'should render ACP fields' do
        r = reg is_confidential_address: '1', ca_type: 'LEO', ca_address: '123', ca_address_2: 'High St', ca_city: 'Bristol', ca_zip5: '12345', ca_zip4: '6789'
        xml.should have_selector "VoterInformation CheckBox[Type='AddressConfidentialityRequest']", text: 'yes'
        xml.within "FurtherInformation Message[Type='Confidential'][DisplayOrder='0001'][Seqn='1']" do |m|
          m.should have_selector "Confidentiality[type='LEO']", text: 'yes'
          m.within "MailingAddress[status='previous'] FreeTextAddress" do |a|
            pending "Format is about to change"
            # a.should have_selector "Thoroughfare[type='PObox'][number='1234']", text: "P.O. Box 1234"
            # a.should have_selector "Locality[type='Town']", text: 'Bristol'
            # a.should have_selector "PostCode[type='ZipCode']", text: '123456789'
            # a.should have_selector "Country[code='USA']", text: 'United States of America'
          end
        end
      end
    end

    describe 'Assistance needed' do
      it 'should render "no"' do
        reg need_assistance: '0'
        xml.should have_selector "VoterInformation CheckBox[Type='RequiresAssistanceToVote']", text: 'no'
      end

      it 'should render "yes"' do
        reg need_assistance: '1'
        xml.should have_selector "VoterInformation CheckBox[Type='RequiresAssistanceToVote']", text: 'yes'
      end
    end
  end

  private

  def xml
    @xml ||= begin
      render
      doc = Nokogiri::XML(rendered)
      doc.remove_namespaces!
      Capybara::Node::Simple.new(doc)
     end
  end


  def reg(o = {})
    @registration = FactoryGirl.build(:existing_residential_voter, o.merge(created_at: Time.now))
  end

  def reg_overseas(o = {})
    @registration = FactoryGirl.build(:existing_overseas_voter, o.merge(created_at: Time.now, residence: 'outside'))
  end

  def reg_absentee(o = {})
    reg({ requesting_absentee: '1', ab_reason: '1A',
      ab_street_number: 3, ab_street_name: 'sn', ab_street_type: 'LN',
      ab_apt: 'apt', ab_city: 'c', ab_state: 'MA', ab_zip5: '33333', ab_zip4: '5555', ab_country: 'co',
      ab_field_1: 'fld1', ab_field_2: 'fld2', ab_time_1: '00:00', ab_time_2: '23:00' }.merge(o))
  end
end
