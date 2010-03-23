require 'pathname'
require Pathname(__FILE__).ascend { |d|
  h = d + 'test_helper.rb'; break h if h.file? }

class UserTest < ActiveSupport::TestCase
  should_validate_presence_of :email

  should "require 6 character password" do
    @new_user = User.new Factory.attributes_for(:user)
    7.times do |n|
      @new_user.password              = "a" * n
      @new_user.password_confirmation = "a" * n
      if n < 6
        assert !@new_user.save, "user shouldn't save with \#{n} char password"
      else
        assert @new_user.save, "user should save with \#{n} char password"
      end
    end
  end

  fast_context "limit role to admin or client" do
    setup do
      @new_user = Factory(:user)
    end

    %w( admin client ).each do |role|
      should "allow \#{role}" do
        @new_user.role = role
        assert @new_user.valid?
        assert_nil @new_user.errors.on(:role)
      end
    end

    should "not allow browser" do
      @new_user.role = 'browser'
      assert !@new_user.valid?
      assert @new_user.errors.on(:role)
    end
  end
end
