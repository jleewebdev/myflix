require "spec_helper"

feature "User registers", {js: true, vcr: true} do

  background do
    visit register_path
  end

  scenario "with valid user info and valid card" do
    fill_in_valid_user_info
    fill_in_valid_card_info
    submit_form
    expect(page).to have_content("Welcome to myFlix! You have successfully registered.")
  end

  scenario "with valid user info and invalid card" do
    fill_in_valid_user_info
    fill_in_invalid_card_info
    submit_form
    expect(page).to have_content("The card number is not a valid credit card number.")
  end

  scenario "with invalid user info and declined card" do
    fill_in_valid_user_info
    fill_in_declined_card
    submit_form
    sleep(1)
    expect(page).to have_content("Your card was declined.")
  end


  scenario "with invalid user info and valid card" do
    fill_in_invalid_user_info
    fill_in_valid_card_info
    submit_form
    expect(page).to have_content("Invalid user information. Please check the errors below.")
  end

  scenario "with invalid user info and invalid card" do
    fill_in_invalid_user_info
    fill_in_invalid_card_info
    submit_form
    sleep(1)
    expect(page).to have_content("The card number is not a valid credit card number.")
  end

  scenario "with invalid user info and declined card" do
    fill_in_invalid_user_info
    fill_in_declined_card
    submit_form
    sleep(1)
    expect(page).to have_content("Invalid user information. Please check the errors below.")
  end

end

def fill_in_valid_user_info
    fill_in "Email Address", with: "josh@example.com"
    fill_in "Password", with: "password"
    fill_in "Full Name", with: "John Doe"
end

def fill_in_valid_card_info
    fill_in "Credit Card Number", with: "4242424242424242"
    fill_in "Security Code", with: "123"
    select "7 - July", from: "date_month"
    select "2018", from: "date_year"
end

def fill_in_invalid_card_info
    fill_in "Credit Card Number", with: "123"
    fill_in "Security Code", with: "123"
    select "7 - July", from: "date_month"
    select "2018", from: "date_year"  
end

def fill_in_declined_card
    fill_in "Credit Card Number", with: "4000000000000002"
    fill_in "Security Code", with: "123"
    select "7 - July", from: "date_month"
    select "2018", from: "date_year"
end


def fill_in_invalid_user_info
  fill_in "Email Address", with: "josh@example.com"
end

def submit_form
  click_button "Sign Up"
end