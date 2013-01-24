module Renderable
  extend ActiveSupport::Concern

  included do
    before_save :render_content, if: Proc.new{|model| model.content.present?}
  end

  private

  def render_content
    @user_ids = Array.new
    require 'redcarpet'
    renderer = Redcarpet::Render::HTML.new link_attributes: {rel: 'nofollow', target: '_blank'}, filter_html: true
    extensions = {space_after_headers: true, no_intra_emphasis: true, tables: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true}
    hashtagged = self.content.gsub(/(^|\s)@([[:alnum:]_-]+)/u) { |tag|
      if user = User.where(name: $2).first
        @user_ids << user.id
        "#{$1}[@#{$2}](#{Rails.application.routes.url_helpers.user_path(user)})"
      else
        tag
      end
    }.gsub(/(^|\s)#([[:alnum:]_-]+)/u) { |tag|
      "#{$1}[##{$2}](#{Rails.application.routes.url_helpers.messages_path(q: $2)})"
    }
    redcarpet = Redcarpet::Markdown.new(renderer, extensions)
    self.rendered_content = redcarpet.render(hashtagged)
  end
end
