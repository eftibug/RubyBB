class Domain < ActiveRecord::Base
  include Renderable

  has_many :users
  has_many :forums
  has_many :topics
  has_many :messages
  has_many :small_messages

  validates_format_of :theme, :with => /^#[0-9a-fA-F]{6}$/
  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_blank => true

  has_attached_file :banner
  attr_accessible :banner, :content, :css, :description, :keywords, :theme, :title, :url
end
