class User < ActiveRecord::Base
  # roles
  ADMIN   = 'admin'
  CLIENT  = 'client'

  # states
  ACTIVE   = 'active'
  DISABLED = 'disabled'

  ## will_paginate
  cattr_reader :per_page
  @@per_page = 10

  ## validations
  validates_presence_of :email
  validates_presence_of :state

  ## authlogic configuration
  acts_as_authentic do |c|
    c.login_field = :email
    c.validate_password_field = true
    c.merge_validates_length_of_password_field_options(:minimum => 6)
    c.merge_validates_length_of_password_confirmation_field_options(:minimum => 6)
  end

  state_machine :state, :initial => :active do
    event :activate do
      transition [:disabled] => :active
    end

    event :disable do
      transition [:active] => :disabled
    end
  end
  named_scope :active, :conditions => {:state => User::ACTIVE}

  ## email
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifications.deliver_password_reset_instructions(self)
  end

  def deliver_approved_notification!
    reset_perishable_token!
    Notifications.deliver_user_approved(self)
  end

  ## authorization: who can do what? Also see app/models/ability.rb
  validates_inclusion_of :role, :in => %w( admin client )
  def admin?
    role == 'admin'
  end

  def client?
    role == 'client'
  end

  named_scope :by_role, lambda {|_role|
    unless _role.nil?
      { :conditions => {:role => _role} }
    end
  }
end

