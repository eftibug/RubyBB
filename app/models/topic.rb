class Topic < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  acts_as_paranoid
  paginates_per 25

  belongs_to :viewer, :class_name => 'User', :foreign_key => 'viewer_id'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
  belongs_to :last_message, :class_name => 'Message', :foreign_key => 'last_message_id'
  belongs_to :user, :counter_cache => true
  belongs_to :forum, :counter_cache => true, :touch => true
  has_many :messages, :include => [:user], :dependent => :destroy
  accepts_nested_attributes_for :messages
  validates :name, :presence => true, :uniqueness => { :scope => :forum_id, :case_sensitive => false }
  validates :forum, :presence => true
  attr_accessible :name, :user_id, :forum_id, :messages_attributes

  has_many :bookmarks
  scope :for_user, lambda { |user| select('topics.*, bookmarks.message_id as bookmarked_id').joins("LEFT JOIN bookmarks ON bookmarks.topic_id = topics.id AND bookmarks.user_id = #{user.try(:id) || user}") }

  after_update :update_counters

  def last_page
    (messages_count.to_f / Message::PER_PAGE).ceil
  end

  def last_page? page
    last_page == (page||1).to_i
  end

  private
  def update_counters
    if forum_id_changed?
      messages.update_all forum_id: forum_id
      Forum.find(forum_id_was).touch
      Forum.update_counters forum_id_was, topics_count: -1, messages_count: -messages_count
      Forum.update_counters forum_id, topics_count: 1, messages_count: messages_count
    end
  end
end
