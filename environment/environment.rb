# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [:active_resource]

  config.gem 'jammit'

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
end

ActiveRecord::Base.schema_format = :sql

require 'paperclip'
Paperclip::Attachment.default_options[:url] = "/system/#{RAILS_ENV}/:class/:attachment/:id/:style/:filename"

ExceptionNotification::Notifier.exception_recipients = %w(adam nick ed john).map {|n| n + "@smartlogicsolutions.com"}
ExceptionNotification::Notifier.sender_address = %("#{RAILS_ENV} Error" <noreply@slsdev.net>)

Haml::Template.options[:format] = :html5
