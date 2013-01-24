class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, Domain
    can :read, Forum
    can :read, Topic
    can :read, Message
    can :read, SmallMessage
    can :read, User

    unless user.new_record?
      can :manage, Domain do |o|
        user.sysadmin?
      end
      can [:manage, :position], Forum do |o|
        user.sysadmin?
      end
      can :create, Topic do |o|
        user.human? || user.topics.empty? || user.sysadmin?
      end
      can :manage, Topic do |o|
        user.id == o.user_id || user.sysadmin?
      end
      can :pin, Topic do |o|
        user.sysadmin?
      end
      can :create, Message do |o|
        user.human? || user.messages.empty? || user.sysadmin?
      end
      can :manage, Message do |o|
        user.id == o.user_id || user.sysadmin?
      end
      can :history, Message do |o|
        user.sysadmin?
      end
      can :create, SmallMessage do |o|
        user.human? || user.sysadmin?
      end
      can :manage, SmallMessage do |o|
        user.id == o.user_id || user.sysadmin?
      end
      can :manage, Bookmark do |o|
        user.id == o.user_id
      end
      can :create, Follow
      can :manage, Follow do |o|
        user.id == o.user_id
      end
      can :read, Notification
      can :manage, Notification do |o|
        user.id == o.user_id
      end
      can :manage, User do |o|
        user.sysadmin?
      end
      can :bot, User do |o|
        user.sysadmin? && !o.human
      end
    end
  end
end
