require 'spec_helper'

describe RegistrationsController do

  let(:af) { stub }
  let(:current_registration) { FactoryGirl.build(:registration) }
  before { controller.stub(:current_registration).and_return(current_registration) }

  describe 'new' do
    before  { controller.should_receive(:no_forms?).and_return(false) }
    before  { RegistrationRepository.should_receive(:pop_search_query).and_return({ first_name: 'Tester' }) }
    before  { ActiveForm.should_receive(:mark!) }
    before  { get :new }
    specify { assigns(:registration).first_name.should == 'Tester' }
  end

  describe 'new when no forms is set' do
    before  { controller.should_receive(:no_forms?).and_return(true) }
    before  { get :new }
    it      { should redirect_to :about_registration_page }
  end

  describe 'create' do
    it 'should not let users finish registration when form expired' do
      ActiveForm.should_receive(:find_for_session!).and_raise(ActiveForm::Expired)
      post :create, registration: {}
      should render_template :expired
    end

    context 'with valid form session' do
      before do
        ActiveForm.should_receive(:find_for_session!).and_return(af)
        af.stub(unmark!: true)
        session[:slr_id] = 'slr_id'
      end

      context 'eligible record' do
        before { Registration.any_instance.should_receive(:eligible?).and_return(true) }

        it 'should save and submit successfully' do
          SubmitEml310.should_receive(:submit_new).with(kind_of(Registration)).and_return(true)
          af.should_receive(:unmark!)
          LogRecord.should_receive(:complete_new).with(kind_of(Registration), 'slr_id')

          post :create, registration: {}
          should render_template :create
          session[:registration_id].should == assigns(:registration).id
          assigns(:registration).reload.submission_failed.should_not be_true
          assigns(:submitted).should be_true
        end

        it 'should mark the record as failed submission' do
          SubmitEml310.should_receive(:submit_new).and_raise(SubmitEml310::SubmissionError)
          post :create, registration: {}
          assigns(:registration).reload.submission_failed.should be_true
        end

        it 'should log the submission of a record with DMV ID' do
          SubmitEml310.stub(submit_new: true)
          LogRecord.should_receive(:submit_new).with(kind_of(Registration), 'slr_id')
          post :create, registration: { dmv_id: '123123123' }
          assigns(:submitted).should be_true
          should render_template :create
        end
      end

      context 'ineligible record' do
        before { Registration.any_instance.should_receive(:eligible?).and_return(false) }
        it 'should mark the record as failed submission' do
          SubmitEml310.should_not_receive(:submit_new)
          post :create, registration: {}
        end
      end

      it 'should return to the form on failure' do
        SubmitEml310.should_not_receive(:submit_new)

        af.should_not_receive(:unmark!)
        af.should_receive(:touch)
        req = mock(save: false)
        Registration.stub(:new).and_return(req)
        post :create, registration: {}
        should render_template :new
        flash[:error].should =~ /review/
      end
    end
  end

  describe 'show' do
    it 'should render template with saved registration' do
      controller.should_receive(:current_registration).and_return(current_registration)
      get :show, format: 'pdf'
      assigns(:pdf).should be
    end

    it 'should redirect to new registration page if there is no registration' do
      controller.should_receive(:current_registration).and_return(nil)
      get :show
      should redirect_to :root
    end
  end

  describe 'show' do
    before  { get :show }
    specify { assigns(:registration).should == current_registration }
    it      { should render_template :show }
  end

  describe 'edit' do
    before  { ActiveForm.should_receive(:mark!) }
    before  { get :edit }
    specify { assigns(:registration).should == current_registration }
    it      { should render_template :edit }
  end

  describe 'update' do
    it 'should not let users finish update when form expired' do
      ActiveForm.should_receive(:find_for_session!).and_raise(ActiveForm::Expired)
      put :update, registration: {}
      should render_template :expired
    end

    context 'with valid form session' do
      before do
        ActiveForm.should_receive(:find_for_session!).and_return(af)
      end

      it 'should set saved lookup DOB' do
        SubmitEml310.stub(:submit_update)
        dob = 40.years.ago
        af.should_receive(:unmark!)
        RegistrationRepository.should_receive(:pop_lookup_data).and_return({ dob: dob })
        put :update, registration: {}
        assigns(:registration).dob.should == dob
      end

      it 'should save valid data' do
        SubmitEml310.should_receive(:submit_update).with(kind_of(Registration))

        af.should_receive(:unmark!)
        current_registration.should_receive(:update_attributes).and_return(true)
        put :update, registration: {}
        assigns(:registration).should == current_registration
        should render_template :update
      end

      it 'should redirect to the form on invalid data' do
        SubmitEml310.should_not_receive(:submit_update)

        af.should_not_receive(:unmark!)
        af.should_receive(:touch)
        current_registration.should_receive(:update_attributes).and_return(false)
        put :update, registration: {}
        should redirect_to :edit_registration
      end
    end
  end
end
