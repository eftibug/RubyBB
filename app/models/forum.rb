class Forum < ActiveRecord::Base
  acts_as_tenant(:domain)
  default_scope order(:position, :parent_id, :slug)

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history, :scoped], :scope => :domain_id

  has_many :children, :class_name => 'Forum', :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => 'Forum', :foreign_key => 'parent_id'
  has_many :topics, :dependent => :destroy
  has_many :follows, :as => :followable, :dependent => :destroy
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
  validates :name, :presence => true, :length => { :maximum => 64 }
  validates_uniqueness_to_tenant :name, :case_sensitive => false
  validates :content, :length => { :maximum => 32768 }

  scope :with_follows, lambda { |user| select('follows.id as follow_id').joins("LEFT JOIN follows ON followable_id = forums.id AND followable_type = 'Forum' AND follows.user_id = #{user.try(:id)}") if user }

  attr_accessible :content, :name, :parent_id
end
