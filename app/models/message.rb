class Message < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Spammable
  include Renderable

  has_paper_trail :only => [:content]

  PER_PAGE = 20
  paginates_per PER_PAGE

  acts_as_tenant(:domain)
  belongs_to :domain, :counter_cache => true
  has_many :notifications, :dependent => :destroy
  has_many :small_messages, :dependent => :destroy
  has_many :follows, :as => :followable, :dependent => :destroy
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
  belongs_to :user, :counter_cache => true
  belongs_to :topic, :counter_cache => true, :touch => true
  belongs_to :forum, :counter_cache => true, :touch => true
  validates :content, :presence => true, :length => { :maximum => 32768 }
  attr_accessible :content, :topic_id

  scope :graph, lambda { select(['date(created_at) as date', 'count(id) as value']).group('date') }
  scope :graph_follows, lambda { select(['date(created_at) as date', 'sum(follows_count) as value']).where('follows_count > ?', 0).group('date') }

  scope :with_follows, lambda { |user| select('follows.id as follow_id').joins("LEFT JOIN follows ON followable_id = messages.id AND followable_type = 'Message' AND follows.user_id = #{user.try(:id)}") if user }

  scope :followed_by, lambda { |user| select('follows.id as follow_id').joins("JOIN follows ON followable_id = messages.id AND followable_type = 'Message' AND follows.user_id = #{user.try(:id)}") if user }

  mapping do
    indexes :id, :index => :not_analyzed
    indexes :content, :analyzer => 'snowball'
    indexes :topic, :as => 'topic.try(:name)', :analyzer => 'snowball'
    indexes :forum, :as => 'forum.try(:name)', :analyzer => 'snowball'
    indexes :domain, :as => 'domain.try(:name)', :analyzer => 'snowball'
    indexes :user, :as => 'user.try(:name)', :analyzer => 'snowball'
    indexes :at, :as => 'created_at', :type => 'date'
  end

  before_save :set_parents
  after_create :update_parents, :autofollow
  after_destroy :decrement_parent_counters
  after_save :fire_notifications

  private

  def autofollow
    Follow.find_or_create_by_followable_type_and_followable_id_and_user_id('Topic', topic_id, user_id)
  end

  def update_parents
    topic.first_message_id = id unless topic.first_message_id
    topic.last_message_id = id
    topic.updater_id = user_id
    topic.save
    forum.update_column :updater_id, user_id
    if forum.parent_id
      Forum.update_counters forum.parent_id, messages_count: 1
    end
  end

  def decrement_parent_counters
    if forum.parent_id
      Forum.update_counters forum.parent_id, messages_count: -1
    end
  end

  def set_parents
    self.forum = Topic.find(topic_id).forum
  end

  def fire_notifications
    @user_ids.each do |uid|
      if uid != self.user_id
        Notification.find_or_create_by_user_id_and_message_id(uid, self.id).touch
      end
    end
    Follow.not_by(self.user_id).where(:followable_id => self.user_id, :followable_type => 'User').each do |f|
      Notification.find_or_create_by_user_id_and_message_id(f.user_id, self.id).touch
    end
    Follow.not_by(self.user_id).where(:followable_id => self.topic_id, :followable_type => 'Topic').each do |f|
      Notification.find_or_create_by_user_id_and_message_id(f.user_id, self.id).touch
    end
    if self.topic.messages_count == 0
      Follow.not_by(self.user_id).where(:followable_id => self.forum_id, :followable_type => 'Forum').each do |f|
        Notification.find_or_create_by_user_id_and_message_id(f.user_id, self.id).touch
      end
    end
  end

end
