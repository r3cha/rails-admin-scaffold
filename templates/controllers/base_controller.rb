# Template: Base Controller for Admin Namespace
#
# Variables to replace:
#   {NAMESPACE} - Module name (e.g., Admin, NewAdmin, Backend)
#   {namespace} - Lowercase namespace (e.g., admin, new_admin, backend)
#   {AUTH_METHOD} - Authentication method (e.g., admin_user, user, none)
#   {PAGINATION_GEM} - pagy, kaminari, or will_paginate
#
# Usage: Copy this template and replace all variables with actual values.

module {NAMESPACE}
  class BaseController < ApplicationController
    # Include pagination backend
    # For pagy:
    include Pagy::Backend
    # For kaminari/will_paginate: no include needed

    # Include admin concerns
    include {NAMESPACE}::DateRangeFilterable
    include {NAMESPACE}::Exportable
    include {NAMESPACE}::BulkActions

    # Authentication
    # For Devise AdminUser:
    # before_action :authenticate_admin_user!
    # For existing User with admin check:
    # before_action :authenticate_user!
    # before_action :require_admin!
    # For HTTP Basic:
    # http_basic_authenticate_with name: "admin", password: ENV["ADMIN_PASSWORD"]
    # For skip: remove authentication

    layout "{namespace}"

    # Sidebar navigation helper
    helper_method :admin_resources

    private

    # Define resources for sidebar navigation
    # Override in subclass or configure dynamically
    def admin_resources
      @admin_resources ||= [
        # Format: { name: "Users", path: {namespace}_users_path, icon: "users", model: User }
        # Will be generated per-project
      ]
    end

    # Pagy configuration
    def pagy_get_vars(collection, vars)
      vars[:items] ||= 25
      vars[:count] ||= collection.count(:all)
      vars
    end

    # For existing User model with admin check
    def require_admin!
      unless current_user&.admin?
        flash[:alert] = "You are not authorized to access this area."
        redirect_to root_path
      end
    end

    # Set flash message based on action result
    def set_flash(type, action, resource_name)
      messages = {
        success: {
          create: "#{resource_name} was successfully created.",
          update: "#{resource_name} was successfully updated.",
          destroy: "#{resource_name} was successfully deleted.",
          restore: "#{resource_name} was successfully restored.",
          bulk_destroy: "Selected records were successfully deleted."
        },
        error: {
          create: "Failed to create #{resource_name.downcase}.",
          update: "Failed to update #{resource_name.downcase}.",
          destroy: "Failed to delete #{resource_name.downcase}.",
          restore: "Failed to restore #{resource_name.downcase}."
        }
      }
      flash[type] = messages[type][action]
    end

    # Common strong parameter filtering for tokens/passwords
    FILTERED_PARAMS = %w[
      encrypted_password
      reset_password_token
      confirmation_token
      unlock_token
      remember_token
      authentication_token
      password_digest
    ].freeze

    def filter_sensitive_params(params_hash)
      params_hash.except(*FILTERED_PARAMS)
    end
  end
end
