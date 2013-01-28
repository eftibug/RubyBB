class Notification < ActiveRecord::Base
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  acts_as_tenant(:domain)
  belongs_to :user
  belongs_to :message

  after_save :update_notifications_count, :publish
  after_destroy :update_notifications_count

  private

  def update_notifications_count
    self.user.update_notifications_count
  end

  def publish
    data = {
      avatar: self.message.user.avatar.exists? ? self.message.user.avatar.url(:x40) : self.message.user.gravatar_url(d: 'retro'),
      title: truncate(self.message.topic.name, length: 20, separator: ' ', omission: '...'),
      content: truncate(self.message.content, length: 24, separator: ' ', omission: '...'),
      count: self.user.notifications_count,
      link: topic_path(self.message.topic) + '?newest'
    }
    PrivatePub.publish_to "/#{self.user_id}/notifications", data
  end
end
