class Domain < ActiveRecord::Base
  has_many :users
  has_many :forums
  has_many :topics
  has_many :messages
  has_many :small_messages

  attr_accessible :banner, :bgcolor, :color, :content, :css, :messages_count, :name, :theme, :title, :topics_count, :url, :users_count
end
