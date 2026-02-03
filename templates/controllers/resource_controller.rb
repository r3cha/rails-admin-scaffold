# Template: Resource Controller for CRUD Operations
#
# Variables to replace:
#   {NAMESPACE} - Module name (e.g., Admin)
#   {namespace} - Lowercase namespace (e.g., admin)
#   {MODEL} - Model class name (e.g., User, BlogPost)
#   {model} - Lowercase singular (e.g., user, blog_post)
#   {models} - Lowercase plural (e.g., users, blog_posts)
#   {PERMITTED_PARAMS} - Array of permitted params [:name, :email, ...]
#   {ASSOCIATIONS} - Associations to preload
#   {SOFT_DELETE} - nil, "paranoia", or "discard"
#
# Usage: Copy this template for each model and replace variables.

module {NAMESPACE}
  class {MODEL}sController < BaseController
    before_action :set_{model}, only: [:show, :edit, :update, :destroy, :restore]

    # GET /{namespace}/{models}
    def index
      @q = {MODEL}.ransack(params[:q])
      @q.sorts = "created_at desc" if @q.sorts.empty?

      # Apply date range filter if provided
      base_scope = apply_date_range_filter({MODEL}.all)

      # Apply soft delete filter
      # For paranoia:
      # base_scope = params[:show_deleted] == "1" ? base_scope.with_deleted : base_scope
      # For discard:
      # base_scope = params[:show_deleted] == "1" ? base_scope.with_discarded : base_scope.kept

      @pagy, @{models} = pagy(@q.result(distinct: true).merge(base_scope))

      respond_to do |format|
        format.html
        format.csv { send_csv_data(@q.result) }
        format.xlsx { send_xlsx_data(@q.result) }
      end
    end

    # GET /{namespace}/{models}/1
    def show
      # Preload associations for display
      # @{model} = @{model}.includes({ASSOCIATIONS})
    end

    # GET /{namespace}/{models}/new
    def new
      @{model} = {MODEL}.new
    end

    # GET /{namespace}/{models}/1/edit
    def edit
    end

    # POST /{namespace}/{models}
    def create
      @{model} = {MODEL}.new({model}_params)

      if @{model}.save
        set_flash(:success, :create, "{MODEL}")
        redirect_to {namespace}_{model}_path(@{model})
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /{namespace}/{models}/1
    def update
      if @{model}.update({model}_params)
        set_flash(:success, :update, "{MODEL}")
        redirect_to {namespace}_{model}_path(@{model})
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /{namespace}/{models}/1
    def destroy
      # Standard delete:
      @{model}.destroy
      # For paranoia: @{model}.destroy (automatically soft deletes)
      # For discard: @{model}.discard

      set_flash(:success, :destroy, "{MODEL}")
      redirect_to {namespace}_{models}_path
    end

    # PATCH /{namespace}/{models}/1/restore (for soft delete)
    def restore
      # For paranoia:
      # @{model}.restore
      # For discard:
      # @{model}.undiscard

      set_flash(:success, :restore, "{MODEL}")
      redirect_to {namespace}_{model}_path(@{model})
    end

    # GET /{namespace}/{models}/export
    def export
      @{models} = {MODEL}.ransack(params[:q]).result

      respond_to do |format|
        format.csv { send_csv_data(@{models}) }
        format.xlsx { send_xlsx_data(@{models}) }
      end
    end

    # DELETE /{namespace}/{models}/bulk_destroy
    def bulk_destroy
      ids = params[:ids] || []
      count = {MODEL}.where(id: ids).destroy_all.count
      # For soft delete:
      # For paranoia: same as above (auto soft deletes)
      # For discard: {MODEL}.where(id: ids).discard_all

      set_flash(:success, :bulk_destroy, "#{count} {models}")
      redirect_to {namespace}_{models}_path
    end

    private

    def set_{model}
      @{model} = {MODEL}.find(params[:id])
      # For soft delete with show_deleted:
      # @{model} = {MODEL}.with_deleted.find(params[:id])  # paranoia
      # @{model} = {MODEL}.with_discarded.find(params[:id])  # discard
    end

    def {model}_params
      params.require(:{model}).permit({PERMITTED_PARAMS})
    end

    # CSV Export
    def send_csv_data(records)
      csv_data = generate_csv(records)
      send_data csv_data,
                filename: "{models}-#{Date.current}.csv",
                type: "text/csv; charset=utf-8"
    end

    def generate_csv(records)
      require "csv"

      attributes = {MODEL}.column_names - %w[encrypted_password]

      CSV.generate(headers: true) do |csv|
        csv << attributes.map(&:humanize)

        records.find_each do |record|
          csv << attributes.map { |attr| format_csv_value(record.send(attr)) }
        end
      end
    end

    def format_csv_value(value)
      case value
      when Time, DateTime
        value.strftime("%Y-%m-%d %H:%M:%S")
      when Date
        value.strftime("%Y-%m-%d")
      when Hash, Array
        value.to_json
      else
        value
      end
    end

    # XLSX Export (requires caxlsx gem)
    def send_xlsx_data(records)
      xlsx_package = generate_xlsx(records)
      send_data xlsx_package.to_stream.read,
                filename: "{models}-#{Date.current}.xlsx",
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end

    def generate_xlsx(records)
      require "caxlsx"

      attributes = {MODEL}.column_names - %w[encrypted_password]

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: "{MODEL}s") do |sheet|
          # Header row
          sheet.add_row attributes.map(&:humanize), style: p.workbook.styles.add_style(b: true)

          # Data rows
          records.find_each do |record|
            sheet.add_row attributes.map { |attr| format_csv_value(record.send(attr)) }
          end
        end
      end
    end
  end
end
