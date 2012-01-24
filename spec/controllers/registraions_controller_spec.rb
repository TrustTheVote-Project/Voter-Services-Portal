require 'spec_helper'

describe RegistrationsController do

  describe 'new' do
    before { LogRecord.should_receive(:log).with('registration', 'started') }
    before { get :new }
    it     { should render_template :new }
  end

end
