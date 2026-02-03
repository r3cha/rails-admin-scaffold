# Template: Minitest Controller Test
#
# Variables to replace:
#   {NAMESPACE} - Module name (e.g., Admin)
#   {namespace} - Lowercase namespace (e.g., admin)
#   {MODEL} - Model class name (e.g., User)
#   {model} - Lowercase singular (e.g., user)
#   {models} - Lowercase plural (e.g., users)
#   {FIXTURE_NAME} - Fixture name (usually :models or :one)
#   {VALID_ATTRIBUTES} - Hash of valid attributes
#   {INVALID_ATTRIBUTES} - Hash of invalid attributes
#   {AUTH_SETUP} - Authentication setup code

require "test_helper"

class {NAMESPACE}::{MODEL}sControllerTest < ActionDispatch::IntegrationTest
  # Include authentication helpers
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)  # or create via fixtures
    sign_in @admin_user

    @{model} = {models}(:one)  # fixture reference
  end

  # Valid attributes for create/update
  def valid_attributes
    # {VALID_ATTRIBUTES}
    {
      # name: "Test Name",
      # email: "test@example.com"
    }
  end

  # Invalid attributes
  def invalid_attributes
    # {INVALID_ATTRIBUTES}
    {
      # name: "",
      # email: "invalid"
    }
  end

  # INDEX
  test "should get index" do
    get {namespace}_{models}_url
    assert_response :success
  end

  test "should filter index by search" do
    get {namespace}_{models}_url, params: { q: { name_cont: @{model}.name } }
    assert_response :success
    assert_includes assigns(:{models}), @{model}
  end

  test "should filter index by date range" do
    get {namespace}_{models}_url, params: {
      date_from: 1.week.ago.to_date,
      date_to: Date.current
    }
    assert_response :success
  end

  # SHOW
  test "should show {model}" do
    get {namespace}_{model}_url(@{model})
    assert_response :success
  end

  # NEW
  test "should get new" do
    get new_{namespace}_{model}_url
    assert_response :success
  end

  # CREATE
  test "should create {model}" do
    assert_difference("{MODEL}.count") do
      post {namespace}_{models}_url, params: { {model}: valid_attributes }
    end

    assert_redirected_to {namespace}_{model}_url({MODEL}.last)
    assert_equal "successfully created", flash[:notice].downcase
  end

  test "should not create {model} with invalid attributes" do
    assert_no_difference("{MODEL}.count") do
      post {namespace}_{models}_url, params: { {model}: invalid_attributes }
    end

    assert_response :unprocessable_entity
  end

  # EDIT
  test "should get edit" do
    get edit_{namespace}_{model}_url(@{model})
    assert_response :success
  end

  # UPDATE
  test "should update {model}" do
    patch {namespace}_{model}_url(@{model}), params: {
      {model}: valid_attributes
    }

    assert_redirected_to {namespace}_{model}_url(@{model})
    assert_equal "successfully updated", flash[:notice].downcase
  end

  test "should not update {model} with invalid attributes" do
    patch {namespace}_{model}_url(@{model}), params: {
      {model}: invalid_attributes
    }

    assert_response :unprocessable_entity
  end

  # DESTROY
  test "should destroy {model}" do
    assert_difference("{MODEL}.count", -1) do
      delete {namespace}_{model}_url(@{model})
    end

    assert_redirected_to {namespace}_{models}_url
    assert_equal "successfully deleted", flash[:notice].downcase
  end

  # EXPORT
  test "should export to CSV" do
    get {namespace}_{models}_url(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.content_type.split(";").first
  end

  test "should export to XLSX" do
    get {namespace}_{models}_url(format: :xlsx)
    assert_response :success
    assert_includes response.content_type, "spreadsheetml"
  end

  test "should export with filters applied" do
    get {namespace}_{models}_url(format: :csv), params: {
      q: { name_cont: @{model}.name }
    }
    assert_response :success
    assert_includes response.body, @{model}.name
  end

  # BULK DESTROY
  test "should bulk destroy selected records" do
    {model}_1 = {MODEL}.create!(valid_attributes)
    {model}_2 = {MODEL}.create!(valid_attributes)

    assert_difference("{MODEL}.count", -2) do
      delete bulk_destroy_{namespace}_{models}_url, params: {
        ids: [{model}_1.id, {model}_2.id]
      }
    end

    assert_redirected_to {namespace}_{models}_url
  end

  test "should handle bulk destroy with no ids" do
    assert_no_difference("{MODEL}.count") do
      delete bulk_destroy_{namespace}_{models}_url, params: { ids: [] }
    end

    assert_redirected_to {namespace}_{models}_url
  end

  # RESTORE (uncomment for soft delete)
  # test "should restore soft deleted {model}" do
  #   @{model}.discard  # or destroy for paranoia
  #
  #   patch restore_{namespace}_{model}_url(@{model})
  #
  #   @{model}.reload
  #   assert_not @{model}.discarded?  # or deleted? for paranoia
  #   assert_redirected_to {namespace}_{model}_url(@{model})
  # end

  # AUTHENTICATION
  test "should redirect unauthenticated user to sign in" do
    sign_out @admin_user

    get {namespace}_{models}_url
    assert_redirected_to new_admin_user_session_url
  end

  # Optional: Authorization tests
  # test "should not allow non-admin user" do
  #   sign_out @admin_user
  #   regular_user = users(:one)
  #   sign_in regular_user
  #
  #   get {namespace}_{models}_url
  #   assert_redirected_to root_url
  # end

  private

  # Helper to create test records
  def create_{model}(attributes = {})
    {MODEL}.create!(valid_attributes.merge(attributes))
  end
end
