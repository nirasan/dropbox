require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe NodesController, type: :controller do
  include Devise::TestHelpers

  let!(:user1) { create(:user) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user1
  end

  let(:valid_attributes_for_file) {
    {user: user1, name:"file1.txt", file: Rails.root.join("spec/factories/files/file1.txt").open, parent_node_id: user1.root_node.id}
  }

  let(:valid_attributes_for_folder) {
    {user: user1, name: 'folder1', parent_node_id: user1.root_node.id}
  }

  let(:invalid_attributes) {
    {user: user1}
  }


  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # NodesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "redirect_to root node" do
      get :index, {}, valid_session
      expect(response).to redirect_to(list_node_path(user1.root_node))
    end
  end

  describe "GET #new_file" do
    it "assigns a parent node as @node" do
      get :new_file, {:id => user1.root_node.to_param}, valid_session
      expect(assigns(:node)).to eq(user1.root_node)
    end
  end

  describe "GET #new_folder" do
    it "assigns a parent node as @node" do
      get :new_file, {:id => user1.root_node.to_param}, valid_session
      expect(assigns(:node)).to eq(user1.root_node)
    end
  end

  describe "GET #edit" do
    it "assigns the requested node as @node" do
      node = Node.create! valid_attributes_for_file
      get :edit, {:id => node.to_param}, valid_session
      expect(assigns(:node)).to eq(node)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Node" do
        expect {
          post :create, {:node => valid_attributes_for_file}, valid_session
        }.to change(Node, :count).by(1)
      end

      it "assigns a newly created node as @node" do
        post :create, {:node => valid_attributes_for_file}, valid_session
        expect(assigns(:node)).to be_a(Node)
        expect(assigns(:node)).to be_persisted
      end

      it "redirects to the created node" do
        post :create, {:node => valid_attributes_for_file}, valid_session
        expect(response).to redirect_to(list_node_path(user1.root_node))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved node as @node" do
        post :create, {:node => invalid_attributes}, valid_session
        expect(assigns(:node)).to be_a_new(Node)
      end

      it "re-renders the 'new' template" do
        post :create, {:node => invalid_attributes}, valid_session
        expect(response).to render_template("new_file")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes_for_folder) {
        {name: "new name"}
      }

      it "updates the requested node" do
        node = Node.create! valid_attributes_for_folder
        put :update, {:id => node.to_param, :node => new_attributes_for_folder}, valid_session
        node.reload
        expect(node.name).to eq("new name")
      end

      it "assigns the requested node as @node" do
        node = Node.create! valid_attributes_for_folder
        put :update, {:id => node.to_param, :node => valid_attributes_for_folder}, valid_session
        expect(assigns(:node)).to eq(node)
      end

      it "redirects to the node" do
        node = Node.create! valid_attributes_for_folder
        put :update, {:id => node.to_param, :node => valid_attributes_for_folder}, valid_session
        expect(response).to redirect_to(list_node_path(node.parent_node))
      end
    end

  end

  describe "DELETE #destroy" do
    it "destroys the requested node" do
      node = Node.create! valid_attributes_for_file
      expect {
        delete :destroy, {:id => node.to_param}, valid_session
      }.to change(Node, :count).by(-1)
    end

    it "redirects to the nodes list" do
      node = Node.create! valid_attributes_for_file
      delete :destroy, {:id => node.to_param}, valid_session
      expect(response).to redirect_to(list_node_path(user1.root_node))
    end
  end

  describe "GET #download" do
    it "return file content" do
      node = Node.create! valid_attributes_for_file
      get :download, {:id => node.to_param}, valid_session
      expect(response.body).to eq(IO.read("spec/factories/files/file1.txt"))
    end
  end

  describe "POST #copy" do
    it "copy node" do
      node = Node.create! valid_attributes_for_file
      expect {
        post :copy, {:id => node.to_param}, valid_session
      }.to change(Node, :count).by(1)
    end
  end

  describe "GET #move_folder_list" do
    let!(:folder1) { create(:node, user: user1, is_folder: true, name: "folder1", parent_node_id: user1.root_node.id) }
    it "assigns the folder tree" do
      node = Node.create! valid_attributes_for_file
      get :move_folder_list, {:id => node.to_param}, valid_session
      expect(assigns(:tree)).to eq({user1.root_node => {folder1 => {}}})
    end
  end

  describe "POST #move" do
    let!(:folder1) { create(:node, user: user1, is_folder: true, name: "folder1", parent_node_id: user1.root_node.id) }
    it "move file to new folder" do
      node = Node.create! valid_attributes_for_file
      post :move, {:id => node.to_param, :node_id => folder1.id}, valid_session
      node.reload
      expect(node.parent_node).to eq(folder1)
    end
  end
end
