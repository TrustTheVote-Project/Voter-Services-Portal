class ActiveForm < ActiveRecord::Base

  class Expired < StandardError; end

  validates :form, presence: true

  scope :expired, lambda { where([ "updated_at < ?", ActiveForm.expiry_period.ago ]) }

  attr_accessor :session

  def self.expiry_period
    AppConfig['form_expiry'].to_i.minutes
  end

  # marks the session with the given action
  def self.mark!(session, registration)
    afid = session[:afid]
    af   = self.where(id: afid).first if afid
    af ||= self.new

    af.form         = registration.uocava? ? "VoterRecordUpdateAbsenteeRequest" : "VoterRegistration"
    af.voter_id     = registration.voter_id
    af.jurisdiction = registration.vvr_county_or_city
    af.save!

    session[:afid] = af.id
    af.session = session

    return af
  end

  def self.find_for_session!(session)
    af = find(session[:afid])
    af.session = session
    af
  rescue ActiveRecord::RecordNotFound
    raise Expired
  end

  # unmarks the session
  def unmark!
    session.delete(:afid)
    destroy
  end

  # sweeps stale records
  def self.sweep
    self.expired.find_each do |af|
      LogRecord.discard(af)
      af.destroy
    end
  end

end
