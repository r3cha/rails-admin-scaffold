# Template: Soft Delete Support Concern
#
# Variables to replace:
#   {NAMESPACE} - Module name (e.g., Admin)
#
# Provides soft delete support for Paranoia and Discard gems.
# Auto-detects which gem is used and provides unified interface.

module {NAMESPACE}
  module SoftDeleteSupport
    extend ActiveSupport::Concern

    included do
      helper_method :soft_delete_enabled?, :record_deleted?, :soft_delete_gem
    end

    private

    # Check if soft delete is enabled for a model
    def soft_delete_enabled?(model_class = nil)
      model_class ||= controller_model_class
      return false unless model_class

      paranoia_enabled?(model_class) || discard_enabled?(model_class)
    end

    # Check which soft delete gem is used
    def soft_delete_gem(model_class = nil)
      model_class ||= controller_model_class
      return nil unless model_class

      return :paranoia if paranoia_enabled?(model_class)
      return :discard if discard_enabled?(model_class)

      nil
    end

    # Check if a record is soft deleted
    def record_deleted?(record)
      return false unless record

      case soft_delete_gem(record.class)
      when :paranoia
        record.deleted?
      when :discard
        record.discarded?
      else
        false
      end
    end

    # Soft delete a record
    def soft_delete_record(record)
      case soft_delete_gem(record.class)
      when :paranoia
        record.destroy # Paranoia overrides destroy to soft delete
      when :discard
        record.discard
      else
        record.destroy # Fall back to hard delete
      end
    end

    # Restore a soft deleted record
    def restore_record(record)
      case soft_delete_gem(record.class)
      when :paranoia
        record.restore
      when :discard
        record.undiscard
      else
        false
      end
    end

    # Get scope including soft deleted records
    def include_deleted_scope(model_class)
      case soft_delete_gem(model_class)
      when :paranoia
        model_class.with_deleted
      when :discard
        model_class.with_discarded
      else
        model_class.all
      end
    end

    # Get scope of only soft deleted records
    def only_deleted_scope(model_class)
      case soft_delete_gem(model_class)
      when :paranoia
        model_class.only_deleted
      when :discard
        model_class.discarded
      else
        model_class.none
      end
    end

    # Get scope excluding soft deleted records
    def without_deleted_scope(model_class)
      case soft_delete_gem(model_class)
      when :paranoia
        model_class.where(deleted_at: nil)
      when :discard
        model_class.kept
      else
        model_class.all
      end
    end

    # Apply soft delete filter based on params
    def apply_soft_delete_filter(scope, model_class = nil)
      model_class ||= scope.klass

      case params[:deleted_filter]
      when "only_deleted"
        only_deleted_scope(model_class).merge(scope)
      when "with_deleted"
        include_deleted_scope(model_class).merge(scope)
      else
        without_deleted_scope(model_class).merge(scope)
      end
    end

    # Check for Paranoia gem
    def paranoia_enabled?(model_class)
      # Paranoia adds acts_as_paranoid class method and deleted_at column
      model_class.respond_to?(:with_deleted) &&
        model_class.column_names.include?("deleted_at")
    end

    # Check for Discard gem
    def discard_enabled?(model_class)
      # Discard adds with_discarded scope and discarded_at column
      model_class.respond_to?(:with_discarded) &&
        model_class.column_names.include?("discarded_at")
    end

    # Get the model class for current controller
    def controller_model_class
      @controller_model_class ||= controller_name.classify.constantize
    rescue NameError
      nil
    end
  end
end
