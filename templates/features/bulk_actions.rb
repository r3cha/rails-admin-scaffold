# Template: Bulk Actions Concern
#
# Variables to replace:
#   {NAMESPACE} - Module name (e.g., Admin)
#
# Provides bulk action functionality for resource controllers.
# Supports bulk delete, restore (for soft delete), and custom actions.

module {NAMESPACE}
  module BulkActions
    extend ActiveSupport::Concern

    included do
      helper_method :bulk_action_available?
    end

    private

    # Perform bulk destroy on selected records
    # Usage: bulk_destroy_records(User, params[:ids])
    def bulk_destroy_records(model_class, ids, options = {})
      return { count: 0, errors: ["No records selected"] } if ids.blank?

      records = model_class.where(id: ids)
      count = records.count

      begin
        if soft_delete_enabled?(model_class)
          # Soft delete
          if model_class.respond_to?(:discard_all)
            # Discard gem
            records.discard_all
          else
            # Paranoia gem or standard destroy (paranoia auto soft-deletes)
            records.destroy_all
          end
        else
          # Hard delete
          records.destroy_all
        end

        { count: count, errors: [] }
      rescue StandardError => e
        { count: 0, errors: [e.message] }
      end
    end

    # Perform bulk restore on soft-deleted records
    # Usage: bulk_restore_records(User, params[:ids])
    def bulk_restore_records(model_class, ids, options = {})
      return { count: 0, errors: ["No records selected"] } if ids.blank?
      return { count: 0, errors: ["Soft delete not enabled"] } unless soft_delete_enabled?(model_class)

      begin
        if model_class.respond_to?(:with_discarded)
          # Discard gem
          records = model_class.with_discarded.where(id: ids).discarded
          count = records.count
          records.each(&:undiscard)
        elsif model_class.respond_to?(:with_deleted)
          # Paranoia gem
          records = model_class.with_deleted.where(id: ids).deleted
          count = records.count
          records.each(&:restore)
        else
          return { count: 0, errors: ["Restore not supported"] }
        end

        { count: count, errors: [] }
      rescue StandardError => e
        { count: 0, errors: [e.message] }
      end
    end

    # Perform custom bulk action
    # Usage: bulk_custom_action(records) { |record| record.archive! }
    def bulk_custom_action(model_class, ids, &block)
      return { count: 0, errors: ["No records selected"] } if ids.blank?
      return { count: 0, errors: ["No action provided"] } unless block_given?

      records = model_class.where(id: ids)
      count = 0
      errors = []

      records.find_each do |record|
        begin
          yield(record)
          count += 1
        rescue StandardError => e
          errors << "#{record.id}: #{e.message}"
        end
      end

      { count: count, errors: errors }
    end

    # Check if soft delete is enabled for a model
    def soft_delete_enabled?(model_class)
      # Discard gem
      return true if model_class.respond_to?(:with_discarded)
      # Paranoia gem
      return true if model_class.respond_to?(:with_deleted)

      false
    end

    # Check if bulk actions are available for current controller
    def bulk_action_available?(action = :destroy)
      case action
      when :destroy
        true # Always available
      when :restore
        soft_delete_enabled?(controller_model_class)
      else
        respond_to?("bulk_#{action}", true)
      end
    end

    # Get the model class for current controller
    # Override in controller if needed
    def controller_model_class
      @controller_model_class ||= controller_name.classify.constantize
    rescue NameError
      nil
    end
  end
end
