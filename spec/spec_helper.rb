# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'turnip/capybara'
require 'capybara/poltergeist'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Dir.glob("spec/acceptance/steps/**/*steps.rb") { |f| load f, true }

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.use_transactional_fixtures = true

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Cleanup
  config.before do
    Registration.delete_all
    @app_config = AppConfig

    # Disable lookup
    AppConfig['enable_dmvid_lookup'] = false
    # Hide privacy act pages
    AppConfig['show_privacy_act_page'] = false
    # Stub out external pages
    ExternalPages.stub(get_from_remote: 'page')
  end

  config.after do
    AppConfig.merge!(@app_config)
  end
end
