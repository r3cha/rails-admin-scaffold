# Template: RSpec Controller Test
#
# Variables to replace:
#   {NAMESPACE} - Module name (e.g., Admin)
#   {namespace} - Lowercase namespace (e.g., admin)
#   {MODEL} - Model class name (e.g., User)
#   {model} - Lowercase singular (e.g., user)
#   {models} - Lowercase plural (e.g., users)
#   {FACTORY_NAME} - Factory bot factory name (usually :model)
#   {VALID_ATTRIBUTES} - Hash of valid attributes for create
#   {INVALID_ATTRIBUTES} - Hash of invalid attributes
#   {AUTH_HELPER} - Authentication helper (sign_in admin_user, etc.)

require "rails_helper"

RSpec.describe {NAMESPACE}::{MODEL}sController, type: :controller do
  # Setup authentication
  let(:admin_user) { create(:admin_user) }

  before do
    # {AUTH_HELPER}
    sign_in admin_user
  end

  # Test data
  let(:valid_attributes) do
    # {VALID_ATTRIBUTES}
    {
      # name: "Test Name",
      # email: "test@example.com"
    }
  end

  let(:invalid_attributes) do
    # {INVALID_ATTRIBUTES}
    {
      # name: "",
      # email: "invalid"
    }
  end

  let(:{model}) { create(:{FACTORY_NAME}) }

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @{models}" do
      {model}
      get :index
      expect(assigns(:{models})).to include({model})
    end

    context "with search params" do
      it "filters results by ransack query" do
        matching = create(:{FACTORY_NAME}, name: "Matching Record")
        non_matching = create(:{FACTORY_NAME}, name: "Other Record")

        get :index, params: { q: { name_cont: "Matching" } }

        expect(assigns(:{models})).to include(matching)
        expect(assigns(:{models})).not_to include(non_matching)
      end
    end

    context "with date range filter" do
      it "filters by date range" do
        old_record = create(:{FACTORY_NAME}, created_at: 1.month.ago)
        new_record = create(:{FACTORY_NAME}, created_at: 1.day.ago)

        get :index, params: { date_from: 1.week.ago.to_date }

        expect(assigns(:{models})).to include(new_record)
        expect(assigns(:{models})).not_to include(old_record)
      end
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { id: {model}.id }
      expect(response).to be_successful
    end

    it "assigns the requested {model}" do
      get :show, params: { id: {model}.id }
      expect(assigns(:{model})).to eq({model})
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end

    it "assigns a new {model}" do
      get :new
      expect(assigns(:{model})).to be_a_new({MODEL})
    end
  end

  describe "GET #edit" do
    it "returns a successful response" do
      get :edit, params: { id: {model}.id }
      expect(response).to be_successful
    end

    it "assigns the requested {model}" do
      get :edit, params: { id: {model}.id }
      expect(assigns(:{model})).to eq({model})
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new {MODEL}" do
        expect {
          post :create, params: { {model}: valid_attributes }
        }.to change({MODEL}, :count).by(1)
      end

      it "redirects to the created {model}" do
        post :create, params: { {model}: valid_attributes }
        expect(response).to redirect_to({namespace}_{model}_path({MODEL}.last))
      end

      it "sets a success flash message" do
        post :create, params: { {model}: valid_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid params" do
      it "does not create a new {MODEL}" do
        expect {
          post :create, params: { {model}: invalid_attributes }
        }.not_to change({MODEL}, :count)
      end

      it "renders the new template" do
        post :create, params: { {model}: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it "returns unprocessable entity status" do
        post :create, params: { {model}: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:new_attributes) do
        # { name: "Updated Name" }
        {}
      end

      it "updates the requested {model}" do
        patch :update, params: { id: {model}.id, {model}: new_attributes }
        {model}.reload
        # expect({model}.name).to eq("Updated Name")
      end

      it "redirects to the {model}" do
        patch :update, params: { id: {model}.id, {model}: new_attributes }
        expect(response).to redirect_to({namespace}_{model}_path({model}))
      end

      it "sets a success flash message" do
        patch :update, params: { id: {model}.id, {model}: new_attributes }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid params" do
      it "renders the edit template" do
        patch :update, params: { id: {model}.id, {model}: invalid_attributes }
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable entity status" do
        patch :update, params: { id: {model}.id, {model}: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested {model}" do
      {model}
      expect {
        delete :destroy, params: { id: {model}.id }
      }.to change({MODEL}, :count).by(-1)
    end

    it "redirects to the {models} list" do
      delete :destroy, params: { id: {model}.id }
      expect(response).to redirect_to({namespace}_{models}_path)
    end

    it "sets a success flash message" do
      delete :destroy, params: { id: {model}.id }
      expect(flash[:notice]).to be_present
    end
  end

  describe "GET #export" do
    before do
      create_list(:{FACTORY_NAME}, 3)
    end

    it "exports to CSV" do
      get :export, format: :csv
      expect(response.content_type).to include("text/csv")
      expect(response).to be_successful
    end

    it "exports to XLSX" do
      get :export, format: :xlsx
      expect(response.content_type).to include("spreadsheetml")
      expect(response).to be_successful
    end

    it "respects search filters in export" do
      matching = create(:{FACTORY_NAME}, name: "Export Me")

      get :export, format: :csv, params: { q: { name_cont: "Export" } }

      expect(response.body).to include("Export Me")
    end
  end

  describe "DELETE #bulk_destroy" do
    let!(:records) { create_list(:{FACTORY_NAME}, 3) }

    it "destroys selected records" do
      ids = records.map(&:id)
      expect {
        delete :bulk_destroy, params: { ids: ids }
      }.to change({MODEL}, :count).by(-3)
    end

    it "redirects to index" do
      delete :bulk_destroy, params: { ids: records.map(&:id) }
      expect(response).to redirect_to({namespace}_{models}_path)
    end

    it "handles empty ids gracefully" do
      expect {
        delete :bulk_destroy, params: { ids: [] }
      }.not_to change({MODEL}, :count)
    end
  end

  # Uncomment for soft delete support
  # describe "PATCH #restore" do
  #   let(:deleted_{model}) do
  #     {model} = create(:{FACTORY_NAME})
  #     {model}.discard  # or {model}.destroy for paranoia
  #     {model}
  #   end
  #
  #   it "restores the record" do
  #     patch :restore, params: { id: deleted_{model}.id }
  #     deleted_{model}.reload
  #     expect(deleted_{model}).not_to be_discarded  # or deleted? for paranoia
  #   end
  #
  #   it "redirects to the restored record" do
  #     patch :restore, params: { id: deleted_{model}.id }
  #     expect(response).to redirect_to({namespace}_{model}_path(deleted_{model}))
  #   end
  # end

  # Authentication tests
  describe "authentication" do
    before { sign_out admin_user }

    it "redirects unauthenticated users" do
      get :index
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end
end
