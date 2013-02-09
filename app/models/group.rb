class Group < ActiveRecord::Base
  acts_as_tenant(:domain)

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history, :scoped], :scope => :domain_id

  paginates_per 25

  has_and_belongs_to_many :users
  belongs_to :user
  attr_accessible :name, :status, :user_ids

  validates :name, :presence => false
  validates :status, :inclusion => { :in => %w[private public] }, :allow_blank => false

  scope :for_user, lambda { |user| where('status = "public" or (status = "private" and user_id = ?)', user.id) }
end
