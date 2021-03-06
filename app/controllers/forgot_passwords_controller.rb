class ForgotPasswordsController < ApplicationController
  def create
    email_input = params[:email]
    user = User.find_by(email: email_input)
    if user
      AppMailer.send_forgot_password(user).deliver
      redirect_to password_confirmation_path
    else
      flash[:error] = email_input.blank? ? "Email cannot be blank" : "Cannot find email"
      redirect_to forgot_password_path
    end
  end

end