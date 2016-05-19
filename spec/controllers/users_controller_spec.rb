require "spec_helper"

describe UsersController do

  describe "GET new" do
    it "sets @user" do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe "POST create" do
    context "with valid input" do

      before { post :create, user: Fabricate.attributes_for(:user) }
 
      it "creates user" do
        expect(User.count).to eq(1)
      end

      it "redirects to the login page" do
        expect(response).to redirect_to videos_path
      end
    end

    context "with invalid input" do

      before { post :create, user: { password: "password", full_name: "Josh Lee"} }

      it "does not create the user" do
        expect(User.count).to eq(0)
      end

      it "render the new template" do
        expect(response).to render_template :new
      end

      it "sets @user" do
        expect(assigns(:user)).to be_instance_of(User)
      end
    end

    context "sending emails" do
        after do
          ActionMailer::Base.deliveries.clear
        end
      it "sends out email to the user with valid inputs" do
        post :create, user: { email: "josh@example.com", password: "password", full_name: "Josh Lee"}
        expect(ActionMailer::Base.deliveries.last.to).to eq(["josh@example.com"])
      end

      it "sends out email containing the user's name with valid inputs" do
        post :create, user: { email: "josh@example.com", password: "password", full_name: "Josh Lee"}
        expect(ActionMailer::Base.deliveries.last.body).to include("Josh Lee")
      end

      it "does not send out email with inputs" do
        post :create, user: { password: "password", full_name: "Josh Lee"}
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe "GET show" do
    it_behaves_like "requires sign in" do
      let(:action) { get :show, id: 3}
    end
  end

  it "sets @user"  do
    set_current_user
    user = Fabricate(:user)
    get :show, id: user.id
    expect(assigns(:user)).to eq(user)
  end

end