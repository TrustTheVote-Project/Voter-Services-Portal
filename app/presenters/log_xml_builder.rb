class LogXmlBuilder

  # builds log records XML
  def self.build(log_records, xml)
    hash = AppConfig['log']['hashalg']

    xml.instruct!
    xml.voterTransactionLog do
      xml.header do
        xml.origin      AppConfig['log']['origin']
        xml.originUniq  AppConfig['log']['origin_uniq']
        xml.hashAlg     hash ? 'SHA1' : 'none'
        xml.createDate  Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      end

      log_records.each do |r|
        xml.voterTransactionRecord do
          xml.action        r.action
          xml.voterid       (hash ? hash_voter_id(r.voter_id) : r.voter_id) || 'na'
          xml.form          r.form unless r.form.blank?
          xml.formNote      'onlineGenerated' unless r.action == 'identify'
          xml.jurisdiction  r.jurisdiction
          xml.notes         'onlineVoterReg'
          # xml.comment       nil
          # xml.leo           nil
          xml.date          r.created_at.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
        end
      end
    end
  end

  private

  def self.hash_voter_id(voter_id)
    voter_id.blank? ? voter_id : Digest::SHA1.hexdigest(voter_id)
  end

end
