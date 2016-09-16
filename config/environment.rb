# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
VaVote::Application.initialize!

ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY" if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
