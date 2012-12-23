class Role < ActiveRecord::Base
  LIST = %w[banned user reader writer moderator admin]
  belongs_to :user
  belongs_to :forum
  validates :name, :inclusion => { :in => LIST }
  attr_accessible :name, :user_id, :forum_id
end
