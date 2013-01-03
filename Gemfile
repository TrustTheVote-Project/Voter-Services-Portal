source 'https://rubygems.org'

gem 'rails', '3.2.9'

gem 'mysql2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
end

gem 'jquery-rails'
gem 'haml-rails'
gem 'rdiscount'
gem 'whenever', :require => false
gem 'inherited_resources'
gem 'kaminari'
gem 'country_select'
gem 'state_select'

gem 'simple_form'

gem 'kronic'
gem 'wicked_pdf', git: 'git://github.com/alg/wicked_pdf.git', branch: 'issue-114'
gem 'nokogiri'
gem 'factory_girl_rails'
gem 'sidekiq'
gem 'jbuilder'

group :development do
  gem 'capistrano'
  gem 'thin'
end

group :test do
  gem 'rspec',        '~> 2.12.0'
  gem 'rspec-rails',  '~> 2.12.0'
  gem 'turnip'
  gem 'poltergeist'
  gem 'faker'
  gem 'timecop'
  gem 'shoulda'
  gem 'guard'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'capybara'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  gem 'sqlite3'
  gem 'pry-rails'
  gem 'pry-debugger'
  gem 'better_errors'
end
