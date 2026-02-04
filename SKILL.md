---
name: rails-admin-scaffold
description: Generate a full-featured CRUD admin panel for Rails 6.1+ applications with auto-detection of CSS frameworks, pagination gems, and smart field mapping
disable-model-invocation: true
---

# Admin Scaffold Generator

Generate a complete admin panel with CRUD operations, filtering, pagination, dashboard, exports, and bulk actions for any Rails 6.1+ application.

## Overview

This skill creates a fully functional admin interface by:
1. Auto-detecting your project's CSS framework, pagination gem, and test framework
2. Analyzing all models for fields, associations, enums, and attachments
3. Asking targeted questions to customize the output
4. Generating controllers, views, routes, and optional tests
5. Providing clear next steps for verification

---

## Phase 1: Detection

Before asking any questions, automatically detect the project configuration.

### 1.1 Check for Existing Admin

```bash
# Check if admin namespace already exists
ls app/controllers/admin/ 2>/dev/null
```

If `app/controllers/admin/` exists:
- Note that admin namespace is taken
- Will suggest `new_admin` or custom namespace in Phase 3

### 1.2 Detect CSS Framework

Read these files to determine CSS framework:

```ruby
# Priority order:
# 1. Tailwind: tailwind.config.js or config/tailwind.config.js exists
# 2. Bootstrap: Gemfile contains 'bootstrap' or package.json contains 'bootstrap'
# 3. Bulma: Gemfile contains 'bulma' or package.json contains 'bulma'
# 4. Default: Tailwind (will need to be added)
```

**Detection logic:**
- Read `tailwind.config.js` or `config/tailwind.config.js` → **Tailwind**
- Read `Gemfile` for `gem 'bootstrap'` or `gem 'cssbundling-rails'` + `package.json` for `bootstrap` → **Bootstrap**
- Read `Gemfile` or `package.json` for `bulma` → **Bulma**

Store result as: `css_framework = "tailwind" | "bootstrap" | "bulma"`

### 1.3 Detect Pagination Gem

Read `Gemfile`:

```ruby
# Look for:
gem 'pagy'           # → pagination_gem = "pagy"
gem 'kaminari'       # → pagination_gem = "kaminari"
gem 'will_paginate'  # → pagination_gem = "will_paginate"
# None found         # → pagination_gem = "pagy" (default, will add to Gemfile)
```

### 1.4 Detect Test Framework

```bash
# Check directory structure:
# spec/ exists → test_framework = "rspec"
# test/ exists → test_framework = "minitest"
```

### 1.5 Detect Stimulus

```ruby
# Check for Stimulus:
# package.json contains "@hotwired/stimulus" → has_stimulus = true
# config/importmap.rb contains "stimulus" → has_stimulus = true
# Otherwise → has_stimulus = false
```

### 1.6 Discover Models

```bash
# List all model files
ls app/models/*.rb
```

Parse each model file to extract:
- Model name (from filename and class definition)
- Skip abstract models, concerns, ApplicationRecord

Store as: `models = ["User", "Post", "Comment", ...]`

### 1.7 Detect Existing Admin Panels

Check for existing admin implementations to understand current patterns:

```ruby
# Check Gemfile for admin gems:
gem 'activeadmin'    # → existing_admin = "activeadmin"
gem 'rails_admin'    # → existing_admin = "rails_admin"
gem 'administrate'   # → existing_admin = "administrate"
```

**If existing admin gem found:**

1. **ActiveAdmin** - Check `app/admin/*.rb` for:
   - Custom form blocks
   - Custom show blocks
   - Filters configuration
   - Batch actions
   - Sidebar sections

2. **RailsAdmin** - Check `config/initializers/rails_admin.rb` for:
   - Custom actions
   - Field configurations
   - Navigation labels

3. **Administrate** - Check `app/dashboards/*_dashboard.rb` for:
   - COLLECTION_ATTRIBUTES
   - SHOW_PAGE_ATTRIBUTES
   - FORM_ATTRIBUTES

**If custom admin exists** (`app/controllers/admin/` without gems):

Analyze existing controllers and views:
```bash
# List existing admin controllers
ls app/controllers/admin/*_controller.rb

# List existing admin views
ls -la app/views/admin/*/
```

For each existing admin resource, extract:
- Custom actions (beyond standard CRUD)
- Custom filters or scopes
- Special display logic in show views
- Custom form fields or nested forms
- Bulk actions
- Export functionality

Store as:
```ruby
existing_admin_features = {
  "User" => {
    custom_actions: ["impersonate", "ban", "export_csv"],
    custom_filters: ["by_role", "by_status", "date_range"],
    nested_forms: ["profile", "addresses"],
    show_sections: ["activity_log", "permissions"],
    bulk_actions: ["activate", "deactivate"]
  },
  # ... other models
}
```

---

## Phase 2: Model Analysis

For each discovered model, extract detailed information.

### 2.1 Schema Information

Look for Annotate gem comments at top of model:

```ruby
# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
```

If no annotation, read `db/schema.rb` for the table definition.

### 2.2 Extract Field Types

Map each column to form input and display type using `reference/field-mappings.md`.

### 2.3 Associations

Look for:
```ruby
belongs_to :author, class_name: 'User'
has_many :comments
has_one :profile
has_and_belongs_to_many :tags
```

### 2.4 Enums

```ruby
enum status: { draft: 0, published: 1, archived: 2 }
enum :role, { admin: 0, user: 1 }, prefix: true  # Rails 7+
```

### 2.5 Active Storage Attachments

```ruby
has_one_attached :avatar
has_many_attached :images
```

### 2.6 Ransack Methods (if existing)

```ruby
def self.ransackable_attributes(auth_object = nil)
  ["email", "name", "created_at"]
end

def self.ransackable_associations(auth_object = nil)
  ["posts", "comments"]
end
```

### 2.7 Soft Delete Detection

```ruby
# Paranoia gem:
acts_as_paranoid

# Discard gem:
include Discard::Model
```

Store soft_delete info: `soft_delete = "paranoia" | "discard" | nil`

---

## Phase 3: Interactive Questions

Use the AskUserQuestion tool with these questions:

### Question 1: Namespace

```json
{
  "question": "What namespace should the admin panel use?",
  "header": "Namespace",
  "options": [
    {"label": "admin", "description": "Standard /admin path (Recommended if not taken)"},
    {"label": "new_admin", "description": "Use /new_admin if /admin exists"},
    {"label": "backend", "description": "Alternative /backend path"},
    {"label": "dashboard", "description": "Use /dashboard path"}
  ],
  "multiSelect": false
}
```

If user selects "Other", use their custom namespace.

### Question 2: Models to Exclude

```json
{
  "question": "Which models should be EXCLUDED from the admin panel?",
  "header": "Exclude",
  "options": [
    {"label": "None - include all", "description": "Generate admin for all models"},
    {"label": "ApplicationRecord only", "description": "Exclude base class only"},
    {"label": "Session/Token models", "description": "Exclude ActiveSession, ApiToken, etc."},
    {"label": "Select specific models", "description": "I'll specify which to exclude"}
  ],
  "multiSelect": false
}
```

If "Select specific models", follow up with multiSelect of model names.

### Question 3: CRUD Views

```json
{
  "question": "Which models need full CRUD (create/edit/delete) views?",
  "header": "CRUD",
  "options": [
    {"label": "All models (Recommended)", "description": "Generate full CRUD for all included models"},
    {"label": "Select models for CRUD", "description": "I'll choose which models get edit forms"},
    {"label": "Read-only for all", "description": "Only index and show views, no editing"}
  ],
  "multiSelect": false
}
```

If "Select models for CRUD", follow up with multiSelect of model names:

```json
{
  "question": "Select models that need create/edit/delete functionality:",
  "header": "Editable",
  "options": [
    // Dynamically generated from included models list
    {"label": "User", "description": "Full CRUD for User"},
    {"label": "Post", "description": "Full CRUD for Post"},
    // ... etc
  ],
  "multiSelect": true
}
```

**Note:** If existing admin panel was detected (Section 1.7), inform user:

```
Detected existing admin panel: {activeadmin|rails_admin|custom}

The following models have custom admin functionality that will be replicated:
- User: custom actions (impersonate, ban), nested forms (profile)
- Order: custom filters (by_status, date_range), export

Do you want to include these custom features?
```

### Question 4: Hidden Fields

```json
{
  "question": "Which fields should be hidden in forms and tables?",
  "header": "Hidden",
  "options": [
    {"label": "Standard (Recommended)", "description": "Hide id, created_at, updated_at, encrypted fields"},
    {"label": "Minimal", "description": "Only hide id and encrypted_password"},
    {"label": "Show all", "description": "Don't hide any fields automatically"},
    {"label": "Extended", "description": "Also hide tokens, confirmation fields, IP addresses"}
  ],
  "multiSelect": false
}
```

### Question 5: Authentication

```json
{
  "question": "How should admin authentication work?",
  "header": "Auth",
  "options": [
    {"label": "Devise AdminUser (Recommended)", "description": "Create separate AdminUser model with Devise"},
    {"label": "Existing User model", "description": "Use current User model with admin role/flag"},
    {"label": "Skip authentication", "description": "No auth - secure with other means"},
    {"label": "HTTP Basic Auth", "description": "Simple username/password protection"}
  ],
  "multiSelect": false
}
```

### Question 6: Internationalization

```json
{
  "question": "Do you want internationalization (i18n) support?",
  "header": "i18n",
  "options": [
    {"label": "No i18n", "description": "English-only, hardcoded strings"},
    {"label": "Yes - English", "description": "i18n with English locale file"},
    {"label": "Yes - Russian", "description": "i18n with Russian locale file"},
    {"label": "Yes - Other language", "description": "I'll specify the language"}
  ],
  "multiSelect": false
}
```

### Question 7: Tests

```json
{
  "question": "Should tests be generated for the admin controllers?",
  "header": "Tests",
  "options": [
    {"label": "Yes (Recommended)", "description": "Generate controller tests"},
    {"label": "No", "description": "Skip test generation"}
  ],
  "multiSelect": false
}
```

### Question 8: Export

```json
{
  "question": "What export functionality do you need?",
  "header": "Export",
  "options": [
    {"label": "CSV with field selection (Recommended)", "description": "Export to CSV, admin chooses which fields"},
    {"label": "CSV + Excel with field selection", "description": "Both formats, admin chooses fields"},
    {"label": "Simple CSV (all fields)", "description": "Quick export without field picker"},
    {"label": "No export", "description": "Skip export functionality"}
  ],
  "multiSelect": false
}
```

---

## Phase 4: Generation

Generate files in this specific order. Use templates from `templates/` directory.

### 4.1 Add Gems (if needed)

If pagination gem not found, add to Gemfile:
```ruby
gem 'pagy', '~> 6.0'
gem 'ransack', '~> 4.0'
```

If Excel export requested:
```ruby
gem 'caxlsx', '~> 4.0'
gem 'caxlsx_rails', '~> 0.6'
```

### 4.2 Create Concerns

Create `app/controllers/concerns/{namespace}/`:

**date_range_filterable.rb** - See `templates/concerns/date_range_filterable.rb`

**exportable.rb** - See `templates/features/export_controller.rb` (extract concern)

**bulk_actions.rb** - See `templates/features/bulk_actions.rb`

### 4.3 Create Base Controller

Use `templates/controllers/base_controller.rb` as template.

Create `app/controllers/{namespace}/base_controller.rb`:

```ruby
module {Namespace}
  class BaseController < ApplicationController
    include Pagy::Backend
    include {Namespace}::DateRangeFilterable
    include {Namespace}::Exportable
    include {Namespace}::BulkActions

    before_action :authenticate_{auth_method}!  # Based on auth choice

    layout "{namespace}"

    private

    def pagy_get_vars(collection, vars)
      vars[:items] ||= 25
      vars[:count] ||= collection.count(:all)
      vars
    end
  end
end
```

### 4.4 Create Layout and Shared Partials

Create `app/views/layouts/{namespace}.html.erb` using `templates/shared/layout.html.erb`.

Create `app/views/{namespace}/shared/` partials:
- `_sidebar.html.erb` - Navigation with all resources
- `_flash.html.erb` - Flash message display
- `_pagination.html.erb` - Pagination controls
- `_table_header.html.erb` - Sortable column headers
- `_bulk_actions.html.erb` - Bulk action dropdown

**IMPORTANT:** Use CSS classes from `css/{css_framework}.md` for all styling.

### 4.5 Create Dashboard

Create `app/controllers/{namespace}/dashboard_controller.rb`:

```ruby
module {Namespace}
  class DashboardController < BaseController
    def index
      @stats = {
        # For each model:
        users: User.count,
        posts: Post.count,
        # etc.
      }

      @recent_activity = [
        # Last 10 records from each model with timestamps
      ]
    end
  end
end
```

Create `app/views/{namespace}/dashboard/index.html.erb` with:
- Stat cards for each model (count, recent count)
- Recent activity feed
- Quick links to each resource

### 4.6 Create Resource Controllers

For each included model, create `app/controllers/{namespace}/{model_plural}_controller.rb`:

Use `templates/controllers/resource_controller.rb` as base.

**Based on CRUD configuration (Question 3):**

**If model has full CRUD:**
- `index` with ransack filtering and pagy pagination
- `show` with association preloading
- `new/create` with strong parameters
- `edit/update` with strong parameters
- `destroy` (or soft delete if detected)
- `export` action for CSV/Excel
- `bulk_destroy` action
- `restore` action (if soft delete)

**If model is read-only:**
- `index` with ransack filtering and pagy pagination
- `show` with association preloading
- `export` action for CSV/Excel
- NO new/create/edit/update/destroy actions

**If existing admin features detected (Section 1.7):**

Replicate custom functionality from existing admin:

```ruby
# Example: If ActiveAdmin had custom action
member_action :impersonate, method: :post do
  # Replicate as:
end

# Becomes in new controller:
def impersonate
  @user = User.find(params[:id])
  # ... implementation
end
```

Include detected features:
- Custom actions → add as controller methods
- Custom filters → add to ransack configuration
- Nested forms → include in strong parameters and form
- Custom show sections → add to show view
- Bulk actions → add to bulk_actions concern

### 4.7 Create Resource Views

For each included model, create views in `app/views/{namespace}/{model_plural}/`:

**Based on CRUD configuration (Question 3):**

#### All models (read-only and CRUD):

**index.html.erb** - Use `templates/views/index.html.erb`:
- Filter form with ransack
- Data table with sortable columns
- Export buttons
- Pagination
- If CRUD: "New" button, bulk action checkboxes, edit/delete links
- If read-only: only "View" links, no bulk actions

**show.html.erb** - Use `templates/views/show.html.erb`:
- Field display based on type
- Associated records lists
- Pretty JSON for jsonb fields
- Image previews for attachments
- If CRUD: Edit, Delete, Back buttons
- If read-only: only Back button

**_table.html.erb** - Use `templates/views/_table.html.erb`

**_filters.html.erb** - Use `templates/views/_filters.html.erb`

#### Only for models with full CRUD:

**new.html.erb** - Use `templates/views/new.html.erb`

**edit.html.erb** - Use `templates/views/edit.html.erb`

**_form.html.erb** - Use `templates/views/_form.html.erb`:
- Form fields based on column types (see field-mappings.md)
- Association selects
- Enum dropdowns
- File upload fields with previews
- JSON textarea for jsonb

#### If existing admin features detected:

Replicate custom view sections from existing admin:
- Custom show page sections → add to show.html.erb
- Custom index columns → add to _table.html.erb
- Custom form fields → add to _form.html.erb
- Nested resource forms → add accepts_nested_attributes and fields_for

### 4.8 Add Ransackable Methods to Models

For each model without existing ransackable methods, add:

```ruby
# In app/models/{model}.rb

def self.ransackable_attributes(auth_object = nil)
  # List of searchable column names
  ["name", "email", "status", "created_at"]
end

def self.ransackable_associations(auth_object = nil)
  # List of searchable association names
  ["author", "comments"]
end
```

### 4.9 Create Routes

Add to `config/routes.rb`:

**Based on CRUD configuration (Question 3):**

```ruby
namespace :{namespace} do
  root to: "dashboard#index"

  # For models with FULL CRUD:
  resources :users do
    collection do
      get :export
      delete :bulk_destroy
    end
    member do
      patch :restore  # Only if soft delete
      # Custom actions from existing admin:
      post :impersonate  # If detected
      post :ban          # If detected
    end
  end

  # For READ-ONLY models:
  resources :audit_logs, only: [:index, :show] do
    collection do
      get :export
    end
  end

  # Repeat for all models...
end
```

### 4.10 Create Stimulus Controllers (if has_stimulus)

Create `app/javascript/controllers/{namespace}/`:

**bulk_select_controller.js**:
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAll", "bulkActions", "selectedCount"]

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

    this.bulkActionsTarget.classList.toggle("hidden", count === 0)
    this.selectedCountTarget.textContent = count

    this.selectAllTarget.checked = count === this.checkboxTargets.length
    this.selectAllTarget.indeterminate = count > 0 && count < this.checkboxTargets.length
  }

  getSelectedIds() {
    return this.checkboxTargets
      .filter(cb => cb.checked)
      .map(cb => cb.value)
  }
}
```

**confirm_controller.js**:
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { message: String }

  confirm(event) {
    if (!window.confirm(this.messageValue || "Are you sure?")) {
      event.preventDefault()
    }
  }
}
```

### 4.11 Create Tests (if requested)

Use templates from `templates/specs/`:

**RSpec** - Create `spec/controllers/{namespace}/` or `spec/requests/{namespace}/`

**Minitest** - Create `test/controllers/{namespace}/`

### 4.12 Create i18n Files (if requested)

Create `config/locales/{namespace}.{locale}.yml`:

```yaml
{locale}:
  {namespace}:
    shared:
      actions: "Actions"
      edit: "Edit"
      delete: "Delete"
      back: "Back"
      save: "Save"
      cancel: "Cancel"
      search: "Search"
      filter: "Filter"
      export: "Export"
      export_csv: "Export CSV"
      export_excel: "Export Excel"
      confirm_delete: "Are you sure you want to delete this record?"
      bulk_delete: "Delete selected"
      no_records: "No records found"
      # ... more keys

    dashboard:
      title: "Dashboard"
      total_records: "Total records"
      recent_activity: "Recent activity"

    # Per-model translations:
    users:
      title: "Users"
      new: "New User"
      edit: "Edit User"
      # field names...
```

---

## Phase 5: Verification

After generation, output these instructions with SPECIFIC details based on user choices:

### Output Template

```markdown
## ✅ Admin Panel Generated Successfully!

### 🔗 Admin Panel URL

**URL:** http://localhost:3000/{namespace}

(Replace `localhost:3000` with your actual host if different)

---

### 🔐 Authentication

{IF auth_choice == "Devise AdminUser"}
**Method:** Devise with AdminUser model

1. Run migrations:
   ```bash
   rails db:migrate
   ```

2. Create your first admin user:
   ```bash
   rails console
   ```
   ```ruby
   AdminUser.create!(email: 'admin@example.com', password: 'password123')
   ```

3. Login at: http://localhost:3000/{namespace}/login
   - Email: admin@example.com
   - Password: password123

{ELSE IF auth_choice == "Existing User model"}
**Method:** Using existing User model with admin check

Make sure your User model has an `admin?` method or `admin` boolean field.
Users with `admin? == true` can access the admin panel.

Login with any admin user credentials at: http://localhost:3000/{namespace}

{ELSE IF auth_choice == "HTTP Basic Auth"}
**Method:** HTTP Basic Authentication

Credentials are set in `app/controllers/{namespace}/base_controller.rb`:
- Username: admin
- Password: (check the controller file)

You can change credentials in the `authenticate` method.

{ELSE IF auth_choice == "Skip authentication"}
**⚠️ WARNING: No authentication configured!**

Your admin panel is currently **publicly accessible**.
This is fine for development, but **NEVER deploy to production without authentication**.

**Recommended:** Add Devise authentication:

1. Add to Gemfile:
   ```ruby
   gem 'devise'
   ```

2. Run:
   ```bash
   bundle install
   rails generate devise:install
   rails generate devise AdminUser
   rails db:migrate
   ```

3. Create admin user:
   ```ruby
   AdminUser.create!(email: 'admin@example.com', password: 'password123')
   ```

4. Add to `app/controllers/{namespace}/base_controller.rb`:
   ```ruby
   before_action :authenticate_admin_user!
   ```

{END IF}

---

### 📁 Files Created

- `app/controllers/{namespace}/` - Admin controllers
- `app/views/{namespace}/` - Admin views
- `app/views/layouts/{namespace}.html.erb` - Admin layout
- `config/routes.rb` - Updated with admin routes
{if tests}- `{spec|test}/controllers/{namespace}/` - Controller tests{/if}
{if i18n}- `config/locales/{namespace}.{locale}.yml` - Translations{/if}

---

### 🚀 Quick Start

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Start server:
   ```bash
   rails server
   ```

3. Open in browser:
   ```
   http://localhost:3000/{namespace}
   ```

---

### 🎨 Customization

- **Navigation:** Edit `app/views/{namespace}/shared/_sidebar.html.erb`
- **Global settings:** Modify `app/controllers/{namespace}/base_controller.rb`
- **Styles:** Adjust the layout file for your design preferences
```

---

## CSS Framework Reference

When generating views, use the appropriate CSS classes based on detected framework.

### Tailwind (Default)
See `css/tailwind.md` for class mappings.

### Bootstrap
See `css/bootstrap.md` for class mappings.

### Bulma
See `css/bulma.md` for class mappings.

---

## Field Type Mappings

See `reference/field-mappings.md` for complete mapping of:
- Database column types → Form input types
- Database column types → Table display formats
- Special handling for JSON, attachments, enums

---

## Patterns Reference

See `reference/patterns.md` for:
- Ransack query patterns
- Pagy/Kaminari/WillPaginate integration
- Soft delete patterns
- Export patterns
- Bulk action patterns
