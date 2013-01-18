FactoryGirl.define do
  factory :user do
    name { Faker::Name.name[0..24] }
    email { Faker::Internet.email }
    password 'password'
    human true

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
    name { Faker::Lorem.sentence(2) }
    after :create do |topic, evaluator|
      FactoryGirl.create_list(:message, 1, topic: topic, user: evaluator.user)
    end
  end

  factory :message, aliases: [:first_message, :last_message] do
    user
    topic
    content { Faker::Lorem.paragraph }
  end

  factory :small_message do
    user
    message
    content { Faker::Lorem.sentence(2) }
  end
end
