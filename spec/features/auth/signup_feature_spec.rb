require 'rails_helper'

feature 'Signup feature' do

  before do
    create(:admin)
    visit new_user_registration_url
  end

  let(:user) { build(:user) }

  scenario 'As a guest I am able to signup from login page' do
    visit new_user_session_url
    click_link('Create a new account')
    expect(page).to have_field('user_email')
    expect(page).to_not have_css('section.first-user')
    expect(page).to_not have_css('#user_admin')
  end

  scenario 'The first user to be created is the admin' do
    User.delete_all
    visit new_user_registration_url
    expect(page).to have_content('Create admin')
    expect(page).to have_css('#user_admin')
  end

  scenario 'As a guest I am able to signup' do
    expect(page).to_not have_content('Create admin')
    fill_in 'user_username', with: user.username
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    fill_in 'user_password_confirmation', with: user.password
    click_button('Create account')
    expect(page).to have_content('Activities')
    expect(current_url).to eq root_url
  end

  scenario 'It always redirects to the signup page when there are no users' do
    User.delete_all

    visit new_user_session_url
    expect(current_url).to eq new_user_registration_url
    visit root_url
    expect(current_url).to eq new_user_registration_url

    expect(page).to have_css('#user_admin')
    expect(page).to have_css('section.first-user')
  end

  scenario 'It does not exist a link to login if there are no users' do
    expect(page).to have_content('Login')

    User.delete_all
    visit new_user_registration_url
    expect(page).to_not have_content('Login')
  end

  scenario 'As a guest I can see error prohibiting my registration to be completed' do
    fill_in 'user_username', with: user.username
    fill_in 'user_email', with: 'gibberish'
    fill_in 'user_password', with: user.password
    fill_in 'user_password_confirmation', with: user.password
    click_button('Create account')
    expect(page).to have_content('Email is invalid')
    expect(page).to_not have_content('Create admin')
    expect(current_url).to eq new_user_registration_url
  end

  scenario 'Multiple errors are displayed in a list' do
    fill_in 'user_username', with: user.username
    fill_in 'user_email', with: 'gibberish'
    fill_in 'user_password', with: '12341234'
    fill_in 'user_password_confirmation', with: '532'
    click_button('Create account')

    expect(page).to have_css('#alert ul')
    expect(page).to have_selector('#alert ul li', count: 2)
    expect(page).to have_selector('#alert ul li', text: 'Email is invalid')
    expect(page).to have_selector('#alert ul li', text: 'Password confirmation doesn\'t match Password')
  end

end
