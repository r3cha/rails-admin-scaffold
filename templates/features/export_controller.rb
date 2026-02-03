# Template: Exportable Concern for CSV/Excel Export
#
# Variables to replace:
#   {NAMESPACE} - Module name (e.g., Admin)
#
# Provides CSV and Excel export functionality for index actions.
# Requires 'caxlsx' gem for Excel export.

module {NAMESPACE}
  module Exportable
    extend ActiveSupport::Concern

    private

    # Generate CSV data from records
    # Usage: send_csv_data(records, filename: "users.csv")
    def export_to_csv(records, options = {})
      model_class = records.klass
      filename = options[:filename] || "#{model_class.table_name}-#{Date.current}.csv"
      columns = export_columns(model_class, options[:columns])

      csv_data = generate_csv(records, columns)
      send_data csv_data,
                filename: filename,
                type: "text/csv; charset=utf-8",
                disposition: "attachment"
    end

    # Generate Excel data from records
    # Requires caxlsx gem
    def export_to_xlsx(records, options = {})
      model_class = records.klass
      filename = options[:filename] || "#{model_class.table_name}-#{Date.current}.xlsx"
      columns = export_columns(model_class, options[:columns])
      sheet_name = options[:sheet_name] || model_class.model_name.human.pluralize

      xlsx_data = generate_xlsx(records, columns, sheet_name)
      send_data xlsx_data,
                filename: filename,
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                disposition: "attachment"
    end

    # Determine which columns to export
    def export_columns(model_class, custom_columns = nil)
      return custom_columns if custom_columns.present?

      # Default: all columns except sensitive ones
      excluded = %w[
        encrypted_password
        reset_password_token
        confirmation_token
        unlock_token
        remember_token
        authentication_token
        password_digest
        password_salt
      ]

      model_class.column_names - excluded
    end

    def generate_csv(records, columns)
      require "csv"

      CSV.generate(headers: true, encoding: "UTF-8") do |csv|
        # Header row
        csv << columns.map { |col| col.to_s.humanize }

        # Data rows
        records.find_each do |record|
          csv << columns.map { |col| format_export_value(record.send(col)) }
        end
      end
    end

    def generate_xlsx(records, columns, sheet_name)
      require "caxlsx"

      package = Axlsx::Package.new
      workbook = package.workbook

      # Styles
      header_style = workbook.styles.add_style(
        b: true,
        bg_color: "4472C4",
        fg_color: "FFFFFF",
        alignment: { horizontal: :center }
      )

      date_style = workbook.styles.add_style(
        format_code: "yyyy-mm-dd"
      )

      datetime_style = workbook.styles.add_style(
        format_code: "yyyy-mm-dd hh:mm:ss"
      )

      workbook.add_worksheet(name: sheet_name.truncate(31)) do |sheet|
        # Header row
        sheet.add_row columns.map { |col| col.to_s.humanize }, style: header_style

        # Data rows
        records.find_each do |record|
          row_data = columns.map { |col| format_export_value(record.send(col)) }
          row_styles = columns.map do |col|
            value = record.send(col)
            case value
            when DateTime, Time
              datetime_style
            when Date
              date_style
            else
              nil
            end
          end

          sheet.add_row row_data, style: row_styles
        end

        # Auto-fit columns (approximate)
        sheet.column_widths(*columns.map { |_| 15 })
      end

      package.to_stream.read
    end

    def format_export_value(value)
      case value
      when Time, DateTime
        value.strftime("%Y-%m-%d %H:%M:%S")
      when Date
        value.strftime("%Y-%m-%d")
      when Hash, Array
        value.to_json
      when TrueClass
        "Yes"
      when FalseClass
        "No"
      when NilClass
        ""
      else
        value.to_s
      end
    end
  end
end
