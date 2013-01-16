require 'spec_helper'

feature 'Visitor visits' do
  scenario 'forums, topics and then messages' do
    forum = create :forum
    topic = create :topic, forum: forum
    message = topic.messages.first
    small_message = create :small_message, forum: forum, topic: topic, message: message

    visit root_path
    expect(page).to have_content(forum.name)
    page.find(:xpath, "//a[@href='#{forum_path(forum)}']").click
    expect(page).to have_content(topic.name)
    page.find(:xpath, "//a[@href='#{topic_path(topic)}']").click
    expect(page).to have_content(message.content)
    expect(page).to have_content(small_message.content)
  end

  scenario 'users and then a profile' do
    user = create :user

    visit users_path
    expect(page).to have_content(user.name)
    page.find(:xpath, "//a[@href='#{user_path(user)}']").click
    expect(page).to have_content(user.name)
  end
end
