class User < ActiveRecord::Base
  # authlogic configuration
  acts_as_authentic do |c|
    c.login_field = :email
    c.validate_password_field = true
    c.merge_validates_length_of_password_field_options(:minimum => 6)
    c.merge_validates_length_of_password_confirmation_field_options(:minimum => 6)
  end

  state_machine :state, :initial => :pending do
    event :approve do
      transition [:pending, :disabled] => :active
    end

    event :deny do
      transition [:pending] => :disabled
    end

    event :disable do
      transition [:active] => :disabled
    end
  end
end
