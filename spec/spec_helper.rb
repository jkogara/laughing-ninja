require 'rspec/autorun'
require 'autotest'
require 'email_spec'
require 'factory_girl'

RSpec.configure do |config|
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
end
