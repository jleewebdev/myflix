class UsersController < ApplicationController

  before_filter :require_user, only: [:show]

  def new
    @user = User.new
  end


   def create
    @user = User.new(user_params)
    
    result = UserSignup.new(@user).sign_up(params[:stripeToken], params[:invitation_token])

    if result.successful?
      flash[:success] = "Welcome to myFlix! You have successfully registered."
      redirect_to sign_in_url
    else
      flash.now[:error] = result.error_message
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit!
  end

  def new_with_invitation
    invitation = Invitation.find_by(token: params[:token])
    if invitation
      @user = User.new(email: invitation.recipient_email)
      @invitation_token = invitation.token
      render :new
    else
      redirect_to expired_token_path
    end
  end


end