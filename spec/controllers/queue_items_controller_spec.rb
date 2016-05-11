require "spec_helper"

describe QueueItemsController do

  let(:alice) {Fabricate(:user) }



  describe "GET index" do
    it "sets @queue_items to the queue items of the logged in user" do
      session[:user_id] = alice.id
      queue_item1 = Fabricate(:queue_item, user: alice)
      queue_item2 = Fabricate(:queue_item, user: alice)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end

    it "redirects to the sign in page for unauthenticated user" do
      get :index
      expect(response).to redirect_to sign_in_path
    end
  end

  describe "POST create" do
    context "while logged in" do
      let(:video) { Fabricate(:video) }

      before do
        session[:user_id] = alice.id

      end
      it "redirects to the my_queue page" do
        post :create, video_id: video.id
        expect(response).to redirect_to my_queue_path
      end

      it "creates the queue item" do
        post :create, video_id: video.id
        expect(QueueItem.count).to eq(1)
      end

      it "creates the queue item that is associated with the video" do
        post :create, video_id: video.id
        expect(QueueItem.first.video).to eq(video)
      end

      it "creates the queue item that is associated with the signed in user" do
        post :create, video_id: video.id
        expect(QueueItem.first.user).to eq(alice)
      end

      it "puts the video as the last one in the queue" do
        monk = Fabricate(:video)
        south_park = Fabricate(:video)
        Fabricate(:queue_item, video: monk, user: alice)
        post :create, video_id: south_park.id
        south_park_queue_item = QueueItem.where(video_id: south_park.id, user_id: alice.id).first
        expect(south_park_queue_item.position).to eq(2)
      end

      it "does not at the video to queue if the video is already in the queue" do
        monk = Fabricate(:video)
        Fabricate(:queue_item, video: monk, user: alice)
        post :create, video_id: monk.id
        expect(alice.queue_items.count).to eq(1)
      end
    end

    it "redirects to the sign in page for unauthenticated users" do
      post :create, video_id: 3
      expect(response).to redirect_to sign_in_path
    end
  end

  describe "DELETE destroy" do
    context "while logged in" do
      before  do
        session[:user_id] = alice.id
      end

      it "redirects to the my queue page" do
        queue_item = Fabricate(:queue_item)
        delete :destroy, id: queue_item.id
        expect(response).to redirect_to my_queue_path
      end

      it "delete the queue item" do
        queue_item = Fabricate(:queue_item, user: alice)
        delete :destroy, id: queue_item.id
        expect(QueueItem.count).to eq(0)
      end

      it "does not delete the queue_item if the current_user doesn't own the item" do
        bob = Fabricate(:user)
        queue_item = Fabricate(:queue_item, user: bob)
        delete :destroy, id: queue_item.id
        expect(QueueItem.count).to eq(1)
      end

      it "normalizes the remaining queue_items" do
        queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)

        delete :destroy, id: queue_item1.id
        expect(QueueItem.first.position).to eq(1)
      end
    end

      it "redirects to the sign_in page for unauthenticated users" do
        delete :destroy, id: 2
        expect(response).to redirect_to sign_in_path
      end
  end

  describe "POST update_queue" do
    context "with valid inputs" do
      it "redirects to the my_queue page" do
          session[:user_id] = alice.id
        queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)

        post :update_queue, queue_items: [ {id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1 } ]

        expect(response).to redirect_to my_queue_path
      end

      it "reorders the queue items" do 
          session[:user_id] = alice.id
        queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)

        post :update_queue, queue_items: [ {id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1 } ]

        expect(alice.queue_items).to eq([queue_item2, queue_item1])

      end

      it "normalizes the position numbers" do
          session[:user_id] = alice.id
        queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)

        post :update_queue, queue_items: [ {id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 3 } ]

        expect(alice.queue_items.map(&:position)).to eq([1, 2])

      end
    end
    context "with invalid inputs" do 
      it "redirects to the my_queue page" do
          session[:user_id] = alice.id
        queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)

        post :update_queue, queue_items: [ {id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 3.5 } ]

        expect(response).to redirect_to my_queue_path
      end

      it "sets the flash error message" do
          session[:user_id] = alice.id
        queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)

        post :update_queue, queue_items: [ {id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 3.5 } ]

        expect(flash[:error]).to be_present

      end

      it "does not change the queue_items" do
          session[:user_id] = alice.id
        queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)

        post :update_queue, queue_items: [ {id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 3.5 } ]

        expect(queue_item1.reload.position).to eq(1)

      end

    end
    
    context "with unauthenticated users" do
      it "redirects to the sign in path" do
        post :update_queue, queue_items: [ {id: 1, position: 2}]
        expect(response).to redirect_to sign_in_path
      end
    end

    context "with queue items that do not belong to the current user" do
      it "does not change the queue_item" do
          bob = Fabricate(:user)
        session[:user_id] = alice.id
        queue_item1 = Fabricate(:queue_item, user: bob, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)

        post :update_queue, queue_items: [ {id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 3 } ]

        expect(queue_item1.reload.position).to eq(1)
      end
    end

  end



end