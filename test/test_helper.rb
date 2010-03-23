ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'
require 'fast_context'
require 'should_change_fast_context'
require 'paperclip/../../shoulda_macros/paperclip'
require 'mocha'
require 'authlogic/test_case'
require 'redgreen'
require 'timecop'
require 'shoulda_ext'
require 'quickerclip'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
