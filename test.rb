# test
gem 'factory_girl'
gem 'shoulda'
gem 'redgreen'
gem 'timecop'
gem 'hydra'
gem 'mocha'

inside ('test') do
  run "mkdir factories"

  file "test_helper.rb", %{
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


  # Log in a given user with authlogic (user passed in through block)
  def self.log_in &block
    setup :activate_authlogic

    setup do
      UserSession.create! block.call
    end
  end
end
}
end

file "lib/shoulda_change_fast_context.rb", <<-END
module Shoulda
  module Macros
    def should_change(description, options = {}, &block)
      by, from, to = get_options!([options], :by, :from, :to)
      stmt = "change \#{description}"
      stmt << " from \#{from.inspect}" if from
      stmt << " to \#{to.inspect}" if to
      stmt << " by \#{by.inspect}" if by

      if block_given?
        code = block
      else
        warn "[DEPRECATION] should_change(expression, options) is deprecated. " <<
             "Use should_change(description, options) { code } instead."
        code = lambda { eval(description) }
      end
      var_name = description_to_variable(description)
      before = lambda { self.instance_variable_set(var_name, code.bind(self).call) }
      should stmt, :before => before do
        old_value = self.instance_variable_get(var_name)
        new_value = code.bind(self).call
        assert_operator from, :===, old_value, "\#{description} did not originally match \#{from.inspect}" if from
        assert_not_equal old_value, new_value, "\#{description} did not change" unless by == 0
        assert_operator to, :===, new_value, "\#{description} was not changed to match \#{to.inspect}" if to
        assert_equal old_value + by, new_value if by
      end
    end

    def should_not_change(description, &block)
      if block_given?
        code = block
      else
        warn "[DEPRECATION] should_not_change(expression) is deprecated. " <<
             "Use should_not_change(description) { code } instead."
        code = lambda { eval(description) }
      end
      var_name = description_to_variable(description) 
      before = lambda { self.instance_variable_set(var_name, code.bind(self).call) }
      should "not change \#{description}", :before => before do
        new_value = code.bind(self).call
        assert_equal self.instance_variable_get(var_name), new_value, "\#{description} changed"
      end
    end

    def description_to_variable(description)
      "@\#{description.gsub(/[^a-z0-9\-_\+]+/i, "_").downcase}_before_should_change"
    end
  end
end
END

run "touch lib/shoulda_ext.rb"

file "lib/quickerclip.rb", %{
module Paperclip
  class Geometry
    def self.from_file file
      parse("100x100")
    end
  end
  class Thumbnail
    def make
      src = Test::FileHelper.fixture_file('white_pixel.jpg')
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode
      FileUtils.cp(src.path, dst.path)
      return dst
    end
  end
end
}
