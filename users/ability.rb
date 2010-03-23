class Ability
  include CanCan::Ability

  def initialize(user)
    can_do_client_things

    if user.admin?
      can_do_admin_things
    end
  end

  def can_do_client_things
    # put user can expressions here
  end

  def can_do_admin_things
    # put admin can expressions here
    can :manage, :all
  end
end
