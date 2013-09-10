require 'spec_helper'

describe BallotInfoPresenter do

  let(:info) { { election: { name: 'Name', date: Date.parse('2013-11-09') }, locality: 'LOC', precinct: '609 - PREC' } }
  subject { BallotInfoPresenter.new(info) }

  its(:election_name) { should eq "Name #{I18n.t('ballot_info.election')}" }
  its(:election_date) { should eq 'November 09, 2013' }
  its(:locality)      { should eq 'Loc' }
  its(:precinct)      { should eq '609 - PREC' }

end
