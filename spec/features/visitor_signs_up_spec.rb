require 'spec_helper'

feature 'Visitor signs up' do
  scenario 'with valid email and password' do
    sign_up_with name: 'Test',
                 email: 'valid@example.com',
                 password: 'password',
                 password_confirmation: 'password'
    expect(page).to have_content('Test')
  end

  scenario 'with invalid email' do
    sign_up_with name: 'Test',
                 email: 'invalid',
                 password: 'password',
                 password_confirmation: 'password'
    expect(page).to have_content('Register')
  end

  scenario 'with blank password' do
    sign_up_with name: 'Test',
                 email: 'valid@example.com',
                 password: '',
                 password_confirmation: ''
    expect(page).to have_content('Register')
  end 

  scenario 'with invalid password confirmation' do
    sign_up_with name: 'Test',
                 email: 'valid@example.com',
                 password: 'password',
                 password_confirmation: 'wordpass'
    expect(page).to have_content('Register')
  end 

  def sign_up_with(user)
    visit new_user_registration_path
    expect(page).to have_content('Register')
    fill_in 'user_name', with: user[:name]
    fill_in 'user_email', with: user[:email]
    fill_in 'user_password', with: user[:password]
    fill_in 'user_password_confirmation', with: user[:password_confirmation]
    click_button 'Sign up'
  end
end
