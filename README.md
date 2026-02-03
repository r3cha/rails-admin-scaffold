# Admin Scaffold - Claude Code Skill

A Claude Code skill that generates a full-featured admin panel for Rails 6.1+ applications.

## Features

- **Auto-Detection**: Automatically detects your CSS framework, pagination gem, and test framework
- **Smart Model Analysis**: Analyzes models for fields, associations, enums, and attachments
- **Multiple CSS Frameworks**: Supports Tailwind CSS, Bootstrap 5, and Bulma
- **Pagination Options**: Works with Pagy, Kaminari, or will_paginate
- **Search & Filtering**: Ransack-powered search with date range filters
- **Export**: CSV and Excel export for all resources
- **Bulk Actions**: Select multiple records for bulk operations
- **Soft Delete Support**: Compatible with Paranoia and Discard gems
- **Active Storage**: Image previews and file attachments
- **Authentication Options**: Devise AdminUser, existing User model, or HTTP Basic Auth
- **Optional Tests**: Generate RSpec or Minitest controller tests
- **i18n Support**: Optional internationalization with multiple languages

## Installation

### Global Installation

Add the skill to your Claude Code settings for use in any project:

```bash
# Create skills directory if it doesn't exist
mkdir -p ~/.claude/skills

# Clone the repository
git clone https://github.com/your-username/rails-admin-scaffold ~/.claude/skills/rails-admin-scaffold
```

Then add to your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "skills": [
    "~/.claude/skills/rails-admin-scaffold/SKILL.md"
  ]
}
```

### Per-Project Installation

Add the skill directly to your Rails project:

```bash
# In your Rails project root
mkdir -p .claude/skills
git clone https://github.com/your-username/rails-admin-scaffold .claude/skills/rails-admin-scaffold
```

Then add to your project's `.claude/settings.json`:

```json
{
  "skills": [
    ".claude/skills/rails-admin-scaffold/SKILL.md"
  ]
}
```

## Usage

In Claude Code, simply run:

```
/rails-admin-scaffold
```

Claude will:

1. **Detect** your project configuration (CSS framework, pagination, tests)
2. **Analyze** all models in `app/models/`
3. **Ask** interactive questions about your preferences
4. **Generate** the admin panel files
5. **Provide** verification instructions

## Generated Structure

```
app/
├── controllers/
│   └── {namespace}/
│       ├── base_controller.rb
│       ├── dashboard_controller.rb
│       ├── users_controller.rb
│       └── ...
├── views/
│   ├── layouts/
│   │   └── {namespace}.html.erb
│   └── {namespace}/
│       ├── shared/
│       │   ├── _sidebar.html.erb
│       │   ├── _flash.html.erb
│       │   └── _pagination.html.erb
│       ├── dashboard/
│       │   └── index.html.erb
│       └── users/
│           ├── index.html.erb
│           ├── show.html.erb
│           ├── new.html.erb
│           ├── edit.html.erb
│           ├── _form.html.erb
│           ├── _table.html.erb
│           └── _filters.html.erb
└── models/
    └── concerns/
        └── {namespace}/
            ├── date_range_filterable.rb
            ├── exportable.rb
            └── bulk_actions.rb
```

## Configuration Options

### Namespace

Choose where your admin panel lives:
- `admin` (default) - `/admin`
- `new_admin` - `/new_admin` (if `/admin` exists)
- `backend` - `/backend`
- `dashboard` - `/dashboard`
- Custom namespace

### Models

Select which models to include or exclude from the admin panel.

### Hidden Fields

Control which fields are hidden in forms and tables:
- **Standard**: id, timestamps, encrypted fields
- **Minimal**: Only id and encrypted_password
- **Extended**: Also hide tokens, IPs, confirmation fields
- **Show all**: Don't hide any fields

### Authentication

- **Devise AdminUser**: Creates a separate AdminUser model
- **Existing User**: Uses your User model with admin role/flag
- **HTTP Basic Auth**: Simple username/password protection
- **Skip**: No authentication (secure via other means)

### Internationalization

- No i18n (English hardcoded)
- i18n with English locale
- i18n with Russian locale
- i18n with custom locale

### Tests

- Generate RSpec controller tests
- Generate Minitest controller tests
- Skip test generation

## Customization

### Styling

Edit the generated layout and partials to customize the look and feel:

- `app/views/layouts/{namespace}.html.erb` - Main layout
- `app/views/{namespace}/shared/_sidebar.html.erb` - Navigation

### Adding Custom Actions

Extend resource controllers with custom actions:

```ruby
# app/controllers/admin/posts_controller.rb
def publish
  @post.update!(status: :published)
  redirect_to admin_post_path(@post), notice: "Post published"
end
```

Don't forget to add routes:

```ruby
# config/routes.rb
namespace :admin do
  resources :posts do
    member do
      patch :publish
    end
  end
end
```

### Custom Filters

Add custom Ransack filters in your models:

```ruby
# app/models/post.rb
def self.ransackable_scopes(auth_object = nil)
  [:published, :draft]
end

scope :published, -> { where(status: :published) }
scope :draft, -> { where(status: :draft) }
```

## Requirements

- Rails 6.1+
- Ruby 3.0+

### Recommended Gems

These gems are added automatically if not present:

```ruby
gem 'ransack', '~> 4.0'  # Search and filtering
gem 'pagy', '~> 6.0'     # Pagination (default)
gem 'caxlsx', '~> 4.0'   # Excel export
gem 'caxlsx_rails'       # Excel export Rails integration
```

## Field Type Support

| Type | Form Input | Table Display |
|------|------------|---------------|
| String | text_field | truncated text |
| Text | text_area | truncated text |
| Integer | number_field | number |
| Float/Decimal | number_field | formatted number |
| Boolean | checkbox | Yes/No badge |
| Date | date_field | formatted date |
| DateTime | datetime_local_field | formatted datetime |
| Enum | select | colored badge |
| JSON/JSONB | text_area | pretty JSON |
| References | collection_select | link to associated |
| Attachment | file_field | thumbnail/link |

## Soft Delete Support

If your models use Paranoia or Discard gems, the admin panel will:

- Show "Deleted at" column in tables
- Add "Show deleted" filter
- Provide "Restore" action instead of/alongside "Delete"
- Support viewing and restoring deleted records

## Export Functionality

Export any resource to CSV or Excel:

- Exports current filtered selection
- Excludes sensitive fields (passwords, tokens)
- Proper formatting for dates, numbers, and JSON
- Headers match field names

## Troubleshooting

### "Admin namespace already exists"

If you already have an admin namespace, the skill will suggest using `new_admin` or a custom namespace.

### "Model not found in schema"

Make sure you've run migrations and the model's table exists in `db/schema.rb`.

### "Pagination gem not detected"

The skill will add Pagy to your Gemfile. Run `bundle install` after generation.

### CSS not loading

Make sure you have the appropriate CSS framework installed and configured:

- **Tailwind**: `tailwind.config.js` should exist
- **Bootstrap**: Bootstrap should be in your asset pipeline
- **Bulma**: Bulma should be in your asset pipeline

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- [Ransack](https://github.com/activerecord-hackery/ransack) for search functionality
- [Pagy](https://github.com/ddnexus/pagy) for pagination
- [caxlsx](https://github.com/caxlsx/caxlsx) for Excel export
