FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password 'password'
    sysadmin false
  end

  factory :admin, class: User do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password 'password'
    sysadmin true
  end
end
