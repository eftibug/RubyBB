# encoding: utf-8
class User < ActiveRecord::Base
  has_many :topics
  has_many :messages
  has_many :bookmarks, :dependent => :destroy
  has_many :follows, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :notified_messages, :through => :notifications, :source => :message

  scope :with_follows, lambda { |user| select('follows.id as follow_id').joins("LEFT JOIN follows ON followable_id = users.id AND followable_type = 'User' AND follows.user_id = #{user.try(:id)}") if user }

  scope :followed_by, lambda { |user| select('follows.id as follow_id').joins("JOIN follows ON followable_id = users.id AND followable_type = 'User' AND follows.user_id = #{user.try(:id)}") if user }

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  paginates_per 25

  include Gravtastic
  gravtastic :size => 100

  attr_accessible :avatar
  has_attached_file :avatar, :styles => {
    :x40 => "40x40^",
    :x64 => "64x64>",
    :x80 => "80x80>",
    :x100 => "100x100>",
    :x128 => "128x128>",
    :x150 => "150x150>",
    :x200 => "200x200>",
    :x256 => "256x256>"
  }, :convert_options => {
    :x40 => "-gravity center -extent 40x40"
  }

  validates :name, :presence => true, :length => { :maximum => 24 }, :uniqueness => { :case_sensitive => false }
  validates :location, :length => { :maximum => 24 }
  validates :website, :length => { :maximum => 255 }
  validates :gender, :inclusion => { :in => %w[male female other] }, :allow_blank => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  attr_accessible :name, :birthdate, :location, :gender, :website, :facebook, :google

  def self.find_for_database_authentication(conditions={})
    self.where("name = ? or email = ?", conditions[:email], conditions[:email]).limit(1).first
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:facebook => auth.uid).first
    unless user
      user = User.where(:facebook => nil, :email => auth.info.email).first
      user.update_column :facebook, auth.uid if user
    end
    unless user
      user = User.create(
        name: auth.extra.raw_info.name,
        facebook: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end

  def self.find_for_google_oauth2(auth, signed_in_resource=nil)
    user = User.where(:google => auth.uid).first
    unless user
      user = User.where(:google => nil, :email => auth.info.email).first
      user.update_column :google, auth.uid if user
    end
    unless user
      user = User.create(name: auth.info.name,
        email: auth.info.email,
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end

  def age
    now = Time.now.utc.to_date
    now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
  end

  def shortname size = 8
    name.size > size ? name.split(' ')[0][0..size-1]+"…" : name
  end

  def update_notifications_count
    self.update_column :notifications_count, Notification.where(user_id: self.id, read: false).count
  end
end
