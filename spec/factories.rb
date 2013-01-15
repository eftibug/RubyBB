FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password 'password'

    factory :admin do
      sysadmin true
    end
  end

  factory :forum do
    name { Faker::Lorem.sentence(2) }
  end

  factory :topic do
    user
    forum
    name { Faker::Lorem.sentence(3) }
    after :create do |topic, evaluator|
      FactoryGirl.create_list(:message, 1, topic: topic, user: evaluator.user, forum: evaluator.forum)
    end
  end

  factory :message, aliases: [:first_message, :last_message] do
    user
    forum
    topic
    content { Faker::Lorem.paragraph }
    rendered_content { "<p>#{content}</p>" }
  end

  factory :small_message do
    user
    forum
    topic
    message
    content { Faker::Lorem.sentence(3) }
  end
end
