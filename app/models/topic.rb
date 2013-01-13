class Topic < ActiveRecord::Base
  include ActionView::Helpers
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  paginates_per 25

  belongs_to :viewer, :class_name => 'User', :foreign_key => 'viewer_id'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
  belongs_to :first_message, :class_name => 'Message', :foreign_key => 'first_message_id'
  belongs_to :last_message, :class_name => 'Message', :foreign_key => 'last_message_id'
  belongs_to :user, :counter_cache => true
  belongs_to :forum, :counter_cache => true, :touch => true
  has_many :messages, :include => [:user], :dependent => :destroy
  has_many :follows, :as => :followable, :dependent => :destroy
  accepts_nested_attributes_for :messages
  validates :name, :presence => true, :length => { :maximum => 64 }, :uniqueness => { :scope => :forum_id, :case_sensitive => false }
  validates :forum, :presence => true
  attr_accessible :name, :forum_id, :messages_attributes

  has_many :bookmarks, :dependent => :destroy

  scope :with_bookmarks, lambda { |user| select('bookmarks.message_id as bookmarked_id').joins("LEFT JOIN bookmarks ON bookmarks.topic_id = topics.id AND bookmarks.user_id = #{user.try(:id)}") if user }

  scope :bookmarked_by, lambda { |user| select('bookmarks.message_id as bookmarked_id').joins("JOIN bookmarks ON bookmarks.topic_id = topics.id AND bookmarks.message_id < topics.last_message_id AND bookmarks.user_id = #{user.try(:id)}") if user }

  scope :with_follows, lambda { |user| select('follows.id as follow_id').joins("LEFT JOIN follows ON followable_id = topics.id AND followable_type = 'Topic' AND follows.user_id = #{user.try(:id)}") if user }

  scope :followed_by, lambda { |user| select('follows.id as follow_id').joins("JOIN follows ON followable_id = topics.id AND followable_type = 'Topic' AND follows.user_id = #{user.try(:id)}") if user }

  after_update :update_counters
  after_create :increment_parent_counters, :autofollow
  after_destroy :decrement_parent_counters

  def preview
    truncate(first_message.content, length: 100, separator: ' ', omission: '...')
  end

  def last_page
    (messages_count.to_f / Message::PER_PAGE).ceil
  end

  def last_page? page
    last_page == (page||1).to_i
  end

  private
  def autofollow
    f = Follow.new(followable_id: id, followable_type: 'Topic')
    f.user_id = user_id
    f.save
  end

  def increment_parent_counters
    if forum.parent_id
      Forum.update_counters forum.parent_id, topics_count: 1
    end
  end

  def decrement_parent_counters
    if forum.parent_id
      Forum.update_counters forum.parent_id, topics_count: -1
    end
  end

  def update_counters
    if forum_id_changed?
      messages.update_all forum_id: forum_id
      was = Forum.find(forum_id_was)
      if was.parent_id != forum.id && was.id != forum.parent_id
        Forum.update_counters forum_id_was, topics_count: -1, messages_count: -messages_count
        Forum.update_counters forum_id, topics_count: 1, messages_count: messages_count
      end
    end
  end
end
