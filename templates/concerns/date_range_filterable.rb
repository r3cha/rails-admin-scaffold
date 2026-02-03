# Template: Date Range Filterable Concern
#
# Variables to replace:
#   {NAMESPACE} - Module name (e.g., Admin)
#
# Provides date range filtering for index actions via params[:date_from] and params[:date_to].

module {NAMESPACE}
  module DateRangeFilterable
    extend ActiveSupport::Concern

    included do
      helper_method :date_range_params
    end

    private

    # Apply date range filter to a scope
    # Usage: apply_date_range_filter(Model.all)
    # Or with custom column: apply_date_range_filter(Model.all, column: :published_at)
    def apply_date_range_filter(scope, column: :created_at)
      scope = scope.where("#{column} >= ?", date_from) if date_from.present?
      scope = scope.where("#{column} <= ?", date_to.end_of_day) if date_to.present?
      scope
    end

    def date_from
      @date_from ||= parse_date(params[:date_from])
    end

    def date_to
      @date_to ||= parse_date(params[:date_to])
    end

    def parse_date(value)
      return nil if value.blank?
      Date.parse(value)
    rescue ArgumentError
      nil
    end

    def date_range_params
      {
        date_from: params[:date_from],
        date_to: params[:date_to]
      }
    end
  end
end
