module AuthenticationHelper
  def sign_in_as(user)
    visit root_path

    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign in"

    assert_text "Sign Out"
  end
end
