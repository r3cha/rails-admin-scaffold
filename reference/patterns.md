# Common Patterns Reference

This document contains proven patterns for admin panel functionality.

## Ransack Query Patterns

### Basic Search Configuration

```ruby
# In model
def self.ransackable_attributes(auth_object = nil)
  %w[name email status created_at updated_at]
end

def self.ransackable_associations(auth_object = nil)
  %w[author category tags]
end

def self.ransortable_attributes(auth_object = nil)
  %w[name created_at updated_at]
end
```

### Controller Search

```ruby
def index
  @q = Model.ransack(params[:q])
  @q.sorts = "created_at desc" if @q.sorts.empty?
  @records = @q.result(distinct: true)
end
```

### Search with Associations

```ruby
def index
  @q = Post.ransack(params[:q])
  @posts = @q.result
             .includes(:author, :category)
             .distinct
end
```

### Combined Text Search

```erb
<%# Search multiple fields with single input %>
<%= f.search_field :title_or_body_or_author_name_cont,
                   placeholder: "Search posts..." %>
```

### Custom Ransacker

```ruby
# In model - search by formatted date
ransacker :created_date do
  Arel.sql("DATE(created_at)")
end

# In model - search by full name
ransacker :full_name do
  Arel.sql("CONCAT(first_name, ' ', last_name)")
end
```

## Pagination Patterns

### Pagy (Recommended)

```ruby
# In controller
include Pagy::Backend

def index
  @pagy, @records = pagy(Model.all, items: 25)
end

# In view
<%== pagy_nav(@pagy) %>
<%= pagy_info(@pagy) %>
```

### Pagy with Ransack

```ruby
def index
  @q = Model.ransack(params[:q])
  @pagy, @records = pagy(@q.result(distinct: true))
end
```

### Kaminari

```ruby
# In controller
def index
  @records = Model.page(params[:page]).per(25)
end

# In view
<%= paginate @records %>
<%= page_entries_info @records %>
```

### will_paginate

```ruby
# In controller
def index
  @records = Model.paginate(page: params[:page], per_page: 25)
end

# In view
<%= will_paginate @records %>
<%= page_entries_info @records %>
```

## Soft Delete Patterns

### Paranoia Gem

```ruby
# Model
class Post < ApplicationRecord
  acts_as_paranoid
end

# Controller - show deleted
def index
  base = params[:show_deleted] ? Post.with_deleted : Post.all
  @posts = base.ransack(params[:q]).result
end

# Controller - restore
def restore
  @post = Post.with_deleted.find(params[:id])
  @post.restore
  redirect_to admin_posts_path, notice: "Post restored"
end

# Controller - permanent delete
def destroy
  @post = Post.with_deleted.find(params[:id])
  if params[:permanent]
    @post.really_destroy!
  else
    @post.destroy
  end
end
```

### Discard Gem

```ruby
# Model
class Post < ApplicationRecord
  include Discard::Model
  default_scope -> { kept }
end

# Controller
def index
  base = params[:show_deleted] ? Post.with_discarded : Post.kept
  @posts = base.ransack(params[:q]).result
end

def destroy
  @post.discard
  redirect_to admin_posts_path, notice: "Post archived"
end

def restore
  @post = Post.with_discarded.find(params[:id])
  @post.undiscard
  redirect_to admin_post_path(@post), notice: "Post restored"
end
```

## Export Patterns

### CSV Export

```ruby
def export
  records = Model.ransack(params[:q]).result

  respond_to do |format|
    format.csv do
      send_data generate_csv(records),
                filename: "#{controller_name}-#{Date.current}.csv",
                type: "text/csv"
    end
  end
end

private

def generate_csv(records)
  require "csv"

  attributes = Model.column_names - %w[encrypted_password]

  CSV.generate(headers: true) do |csv|
    csv << attributes.map(&:humanize)

    records.find_each do |record|
      csv << attributes.map { |attr| record.send(attr) }
    end
  end
end
```

### Excel Export (caxlsx)

```ruby
def export
  records = Model.ransack(params[:q]).result

  respond_to do |format|
    format.xlsx do
      package = generate_xlsx(records)
      send_data package.to_stream.read,
                filename: "#{controller_name}-#{Date.current}.xlsx",
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end
  end
end

private

def generate_xlsx(records)
  require "caxlsx"

  attributes = Model.column_names - %w[encrypted_password]

  Axlsx::Package.new do |p|
    p.workbook.add_worksheet(name: "Data") do |sheet|
      # Header
      sheet.add_row attributes.map(&:humanize),
                    style: p.workbook.styles.add_style(b: true)

      # Data
      records.find_each do |record|
        sheet.add_row attributes.map { |attr| record.send(attr) }
      end
    end
  end
end
```

## Bulk Actions Patterns

### Bulk Delete

```ruby
# Controller
def bulk_destroy
  ids = params[:ids] || []
  count = Model.where(id: ids).destroy_all.count
  redirect_to admin_models_path, notice: "#{count} records deleted"
end

# Routes
resources :models do
  collection do
    delete :bulk_destroy
  end
end
```

### View with Checkboxes

```erb
<%# Table header %>
<th>
  <input type="checkbox" id="select-all">
</th>

<%# Table row %>
<td>
  <input type="checkbox" class="row-checkbox" name="ids[]" value="<%= record.id %>">
</td>

<%# Bulk action form %>
<%= form_tag bulk_destroy_admin_models_path, method: :delete, id: "bulk-form" do %>
  <button type="submit" data-confirm="Delete selected records?">
    Delete Selected
  </button>
<% end %>

<script>
document.getElementById('select-all').addEventListener('change', function() {
  document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = this.checked);
});
</script>
```

### Stimulus Controller for Bulk Selection

```javascript
// bulk_select_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAll", "bulkActions", "count", "form"]

  connect() {
    this.updateUI()
  }

  toggleAll() {
    const checked = this.selectAllTarget.checked
    this.checkboxTargets.forEach(cb => cb.checked = checked)
    this.updateUI()
  }

  toggle() {
    this.updateUI()
  }

  updateUI() {
    const checked = this.checkboxTargets.filter(cb => cb.checked)
    const count = checked.length

    // Show/hide bulk actions bar
    this.bulkActionsTarget.classList.toggle("hidden", count === 0)
    this.countTarget.textContent = count

    // Update select all state
    this.selectAllTarget.checked = count === this.checkboxTargets.length
    this.selectAllTarget.indeterminate = count > 0 && count < this.checkboxTargets.length
  }

  submitBulk(event) {
    const form = this.formTarget
    const ids = this.checkboxTargets.filter(cb => cb.checked).map(cb => cb.value)

    // Clear existing hidden inputs
    form.querySelectorAll('input[name="ids[]"]').forEach(el => el.remove())

    // Add selected ids
    ids.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "ids[]"
      input.value = id
      form.appendChild(input)
    })
  }
}
```

## Authentication Patterns

### Devise with AdminUser

```ruby
# Generate AdminUser
# rails generate devise AdminUser

# Controller
class Admin::BaseController < ApplicationController
  before_action :authenticate_admin_user!
  layout "admin"
end
```

### Existing User with Admin Role

```ruby
# Migration
add_column :users, :admin, :boolean, default: false

# Controller
class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  private

  def require_admin!
    unless current_user&.admin?
      flash[:alert] = "Access denied"
      redirect_to root_path
    end
  end
end
```

### HTTP Basic Auth

```ruby
class Admin::BaseController < ApplicationController
  http_basic_authenticate_with(
    name: ENV["ADMIN_USERNAME"] || "admin",
    password: ENV["ADMIN_PASSWORD"] || "password"
  )
end
```

## Route Patterns

### Standard Admin Namespace

```ruby
namespace :admin do
  root to: "dashboard#index"

  resources :users do
    member do
      patch :restore
    end
    collection do
      get :export
      delete :bulk_destroy
    end
  end

  resources :posts do
    member do
      patch :restore
      patch :publish
      patch :unpublish
    end
    collection do
      get :export
      delete :bulk_destroy
    end
  end
end
```

### Constraints for Security

```ruby
namespace :admin do
  constraints lambda { |req| req.session[:admin_id].present? } do
    # Admin routes
  end
end
```

## Flash Message Patterns

```ruby
# Controller concern
module Flashable
  extend ActiveSupport::Concern

  private

  def flash_success(action, resource_name)
    flash[:notice] = t("admin.flash.#{action}.success", resource: resource_name)
  end

  def flash_error(action, resource_name)
    flash[:alert] = t("admin.flash.#{action}.error", resource: resource_name)
  end
end
```

## Strong Parameters Patterns

### Dynamic Permitted Params

```ruby
def model_params
  params.require(:model).permit(permitted_attributes)
end

private

def permitted_attributes
  # Base attributes
  attrs = [:name, :email, :status]

  # Add association ids
  attrs << :category_id if Model.reflect_on_association(:category)

  # Add tag_ids for has_many through
  attrs << { tag_ids: [] } if Model.reflect_on_association(:tags)

  # Add attachments
  attrs << :avatar if Model.reflect_on_attachment(:avatar)
  attrs << { images: [] } if Model.reflect_on_attachment(:images)

  attrs
end
```

### Filtering Sensitive Params

```ruby
SENSITIVE_PARAMS = %w[
  encrypted_password reset_password_token confirmation_token
  unlock_token remember_token authentication_token
].freeze

def filtered_params
  params.require(:user).permit(User.column_names - SENSITIVE_PARAMS)
end
```

## Date Range Filter Pattern

```ruby
# Controller concern
module DateRangeFilterable
  extend ActiveSupport::Concern

  private

  def apply_date_filter(scope, column: :created_at)
    scope = scope.where("#{column} >= ?", date_from) if date_from
    scope = scope.where("#{column} <= ?", date_to.end_of_day) if date_to
    scope
  end

  def date_from
    Date.parse(params[:date_from]) rescue nil
  end

  def date_to
    Date.parse(params[:date_to]) rescue nil
  end
end

# View
<div class="filter-group">
  <%= text_field_tag :date_from, params[:date_from], type: :date, placeholder: "From" %>
  <%= text_field_tag :date_to, params[:date_to], type: :date, placeholder: "To" %>
</div>
```

## Turbo/Hotwire Patterns

### Turbo Frame for Inline Edit

```erb
<%# index.html.erb %>
<%= turbo_frame_tag dom_id(record) do %>
  <tr>
    <td><%= record.name %></td>
    <td><%= link_to "Edit", edit_admin_model_path(record) %></td>
  </tr>
<% end %>

<%# edit.html.erb %>
<%= turbo_frame_tag dom_id(@record) do %>
  <%= form_with model: [:admin, @record] do |f| %>
    <tr>
      <td><%= f.text_field :name %></td>
      <td><%= f.submit "Save" %></td>
    </tr>
  <% end %>
<% end %>
```

### Turbo Stream for Delete

```ruby
# Controller
def destroy
  @record.destroy
  respond_to do |format|
    format.turbo_stream { render turbo_stream: turbo_stream.remove(@record) }
    format.html { redirect_to admin_models_path }
  end
end
```
