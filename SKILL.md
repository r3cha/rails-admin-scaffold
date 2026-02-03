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

### Question 3: Hidden Fields

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

### Question 4: Authentication

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

### Question 5: Internationalization

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

### Question 6: Tests

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

Key features:
- `index` with ransack filtering and pagy pagination
- `show` with association preloading
- `new/create` with strong parameters
- `edit/update` with strong parameters
- `destroy` (or soft delete if detected)
- `export` action for CSV/Excel
- `bulk_destroy` action
- `restore` action (if soft delete)

### 4.7 Create Resource Views

For each included model, create views in `app/views/{namespace}/{model_plural}/`:

**index.html.erb** - Use `templates/views/index.html.erb`:
- Filter form with ransack
- Data table with sortable columns
- Bulk action checkboxes
- Export buttons
- Pagination

**show.html.erb** - Use `templates/views/show.html.erb`:
- Field display based on type
- Associated records lists
- Action buttons (Edit, Delete, Back)
- Pretty JSON for jsonb fields
- Image previews for attachments

**new.html.erb** - Use `templates/views/new.html.erb`

**edit.html.erb** - Use `templates/views/edit.html.erb`

**_form.html.erb** - Use `templates/views/_form.html.erb`:
- Form fields based on column types (see field-mappings.md)
- Association selects
- Enum dropdowns
- File upload fields with previews
- JSON textarea for jsonb

**_table.html.erb** - Use `templates/views/_table.html.erb`

**_filters.html.erb** - Use `templates/views/_filters.html.erb`

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

```ruby
namespace :{namespace} do
  root to: "dashboard#index"

  # For each model:
  resources :users do
    collection do
      get :export
      delete :bulk_destroy
    end
    member do
      patch :restore  # Only if soft delete
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

After generation, output these instructions:

```markdown
## Admin Panel Generated Successfully!

### Next Steps:

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Run migrations (if AdminUser created):**
   ```bash
   rails db:migrate
   ```

3. **Create admin user (if using Devise AdminUser):**
   ```bash
   rails console
   AdminUser.create!(email: 'admin@example.com', password: 'password123')
   ```

4. **Start server:**
   ```bash
   rails server
   ```

5. **Visit admin panel:**
   ```
   http://localhost:3000/{namespace}
   ```

### Files Created:
- `app/controllers/{namespace}/` - Admin controllers
- `app/views/{namespace}/` - Admin views
- `app/views/layouts/{namespace}.html.erb` - Admin layout
- `config/routes.rb` - Updated with admin routes
{if tests}- `{spec|test}/controllers/{namespace}/` - Controller tests{/if}
{if i18n}- `config/locales/{namespace}.{locale}.yml` - Translations{/if}

### Customization:
- Edit `app/views/{namespace}/shared/_sidebar.html.erb` to customize navigation
- Modify `app/controllers/{namespace}/base_controller.rb` for global settings
- Adjust styles in the layout file for your design preferences
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
