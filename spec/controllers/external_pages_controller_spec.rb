require 'spec_helper'

describe ExternalPagesController do

  it 'should load an external page' do
    VCR.use_cassette('external_page_about') do
      get :show, id: 'about'
      response.body.should include "Voter Services"
    end
  end

  it 'should return help message for unknown pages' do
    VCR.use_cassette('external_page_unknown') do
      get :show, id: 'unknown'
      response.body.should == 'Page not found (unknown.htm).'
    end
  end
end
