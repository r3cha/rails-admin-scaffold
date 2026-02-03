# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code skill** (not a gem or Rails app) that generates full-featured CRUD admin panels for Rails 6.1+ applications. The skill is invoked via `/rails-admin-scaffold` command.

## Repository Structure

```
├── SKILL.md              # Main skill definition with 5-phase workflow
├── README.md             # User documentation
├── css/                  # CSS framework class mappings
│   ├── tailwind.md       # Tailwind CSS classes
│   ├── bootstrap.md      # Bootstrap 5 classes
│   └── bulma.md          # Bulma classes
├── reference/            # Pattern and mapping reference
│   ├── field-mappings.md # DB column → form input mappings
│   ├── patterns.md       # Implementation patterns (Ransack, pagination, etc.)
│   └── model-analysis.md # Model analysis strategies
└── templates/            # Code generation templates
    ├── controllers/      # Base and resource controller templates
    ├── views/            # ERB view templates (index, show, new, edit, partials)
    ├── shared/           # Layout, sidebar, flash, pagination partials
    ├── dashboard/        # Dashboard controller and view
    ├── concerns/         # DateRangeFilterable concern
    ├── features/         # Bulk actions, export, soft delete
    └── specs/            # RSpec and Minitest test templates
```

## Key Architecture Concepts

**Template Placeholders:** All templates use placeholders that get replaced during generation:
- `{NAMESPACE}` - Admin namespace (admin, backend, etc.)
- `{MODEL}` - Model class name
- `{models}` - Pluralized model name
- `{CSS: class-name}` - Framework-agnostic CSS class tokens

**5-Phase Workflow:**

```
/rails-admin-scaffold
    │
    ▼
┌─────────────────────────────────────────┐
│  Phase 1: DETECTION                     │
│  - Check app/controllers/admin/         │
│  - Detect CSS framework                 │
│  - Detect pagination gem                │
│  - Collect list of models               │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│  Phase 2: MODEL ANALYSIS                │
│  For each model:                        │
│  - Parse schema (annotate block)        │
│  - Determine column types               │
│  - Find associations                    │
│  - Find enums                           │
│  - Check ransackable_*                  │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│  Phase 3: INTERACTIVE QUESTIONS         │
│  AskUserQuestion for:                   │
│  1. Namespace (admin / new_admin)       │
│  2. Models to exclude                   │
│  3. Fields to hide in tables            │
│  4. Authentication (Devise?)            │
│  5. i18n support                        │
│  6. Test generation                     │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│  Phase 4: GENERATION                    │
│  - Shared infrastructure (concerns)     │
│  - Controllers for each model           │
│  - Views (index, show, new, edit)       │
│  - Partials (_table, _form, _filters)   │
│  - Routes                               │
│  - Model modifications (ransackable)    │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│  Phase 5: VERIFICATION                  │
│  - Gem installation instructions        │
│  - Commands for verification            │
└─────────────────────────────────────────┘
```

**Framework Abstraction:** CSS classes are defined separately in `css/*.md` files, allowing the same templates to work with Tailwind, Bootstrap, or Bulma.

## How the Skill Works

### Phase 1: Detection Logic

**CSS Framework detection order:**
1. `tailwind.config.js` or `config/tailwind.config.js` → Tailwind
2. `bootstrap` in Gemfile or package.json → Bootstrap
3. `bulma` in package.json → Bulma
4. Default → Tailwind

**Pagination detection (Gemfile):**
- `pagy` → Pagy (recommended)
- `kaminari` → Kaminari
- `will_paginate` → will_paginate
- None → add Pagy

**Models discovery:**
- Scan `app/models/*.rb`
- Filter out: `application_record.rb`, `concerns/`, abstract classes

### Phase 2: Model Analysis

For each model, extract:
- **Schema** — parse annotate block comments
- **Column types** — map to form inputs (see `reference/field-mappings.md`)
- **Associations** — `belongs_to` → select, `has_many` → count in table
- **Enums** — generate select options
- **Attachments** — Active Storage file fields

### Phase 4: Generation Order

1. **Concerns** — `app/controllers/concerns/{ns}/date_range_filterable.rb`
2. **Base Controller** — `app/controllers/{ns}/base_controller.rb`
3. **Layout & Shared Partials** — layout, sidebar, table_layout, filter_bar, pagination
4. **Per-Model Files** — controller + views (index, show, new, edit) + partials (_table, _form, _filters)
5. **Model Modifications** — add `ransackable_attributes`, `ransackable_associations`
6. **Routes** — namespace block with all resources
7. **Gemfile** — ransack, pagy (if needed)

### Key Rails Patterns Used

```ruby
# Controller index pattern
def index
  @query = Model.includes(:association).ransack(query_params)
  @query.sorts = ["created_at desc"] if @query.sorts.empty?
  @pagy, @records = pagy(@query.result(distinct: true), limit: 25)
end

# Ransack configuration in models
def self.ransackable_attributes(auth_object = nil)
  %w[name email status created_at updated_at]
end

def self.ransackable_associations(auth_object = nil)
  %w[organization team]
end
```

## Development Notes

- This is a pure documentation/template repository with no dependencies or tests
- Changes to templates affect all generated admin panels
- When modifying templates, ensure placeholders are consistent across related files
- Reference patterns in `reference/patterns.md` for established Rails patterns used by the skill
