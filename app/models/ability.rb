class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, Forum do |o|
      o.reader == 'banned'
    end
    can :read, Topic do |o|
      o.forum.reader == 'banned'
    end
    can :read, Message do |o|
      o.forum.reader == 'banned'
    end
    can :read, SmallMessage do |o|
      o.forum.reader == 'banned'
    end
    can :read, User

    unless user.new_record?
      can :read, Forum do |o|
        %w[banned user].include?(o.reader) || user.reader?(o.id)
      end
      can :read, Topic do |o|
        %w[banned user].include?(o.forum.reader) || user.reader?(o.forum_id)
      end
      can :read, Message do |o|
        %w[banned user].include?(o.forum.reader) || user.reader?(o.forum_id)
      end
      can :read, SmallMessage do |o|
        %w[banned user].include?(o.forum.reader) || user.reader?(o.forum_id)
      end

      can :create, Topic do |o|
        (o.forum.writer == 'user' && !user.banned?(o.forum_id) && (user.human? || user.topics.empty?)) ||
        user.writer?(o.forum_id)
      end
      can :create, Message do |o|
        (o.forum.writer == 'user' && !user.banned?(o.forum_id) && (user.human? || user.messages.empty?)) ||
        user.writer?(o.forum_id)
      end
      can :create, SmallMessage do |o|
        (o.forum.writer == 'user' && !user.banned?(o.forum_id) && user.human?) ||
        user.writer?(o.forum_id)
      end

      can [:read, :clear], Bookmark
      can [:read, :clear], Notification
      can [:create, :read], Follow do |o|
        r = o.followable_type == 'User'
        if o.followable_type == 'Forum'
          r = %w[banned user].include?(o.reader) || user.reader?(o.id)
        elsif o.followable.has_attribute? :forum_id
          r = %w[banned user].include?(o.forum.reader) || user.reader?(o.forum_id)
        end
        r
      end

      can :manage, Notification do |o|
        user.id == o.user_id
      end

      can :manage, Follow do |o|
        user.id == o.user_id
      end

      can :manage, SmallMessage do |o|
        user.id == o.user_id || user.moderator?(o.forum_id)
      end

      can :manage, Message do |o|
        user.id == o.user_id || user.moderator?(o.forum_id)
      end

      can :manage, Topic do |o|
        user.id == o.user_id || user.admin?(o.forum_id)
      end

      can :pin, Topic do |o|
        user.admin?(o.forum_id)
      end

      can [:create, :position], Forum do |o|
        user.sysadmin?
      end

      can [:update, :destroy], Forum do |o|
        user.admin?(o.id)
      end

      can :manage, Role do |o|
        (!o.user || !o.user.sysadmin?) && o.user_id != user.id &&
        user.admin?(o.forum_id)
      end

      can :manage, User do |o|
        user.sysadmin?
      end

      can :bot, User do |o|
        user.moderator?(o.messages.first.try(:forum_id)) && !o.human
      end
    end
  end
end
