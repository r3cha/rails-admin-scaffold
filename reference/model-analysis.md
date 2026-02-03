# Model Analysis Reference

This document describes how to analyze Rails models for admin scaffold generation.

## Overview

Model analysis extracts the following information:
1. Schema (columns, types, constraints)
2. Associations (belongs_to, has_many, has_one, has_and_belongs_to_many)
3. Enums
4. Active Storage attachments
5. Validations (for required fields)
6. Ransackable methods (existing search configuration)
7. Soft delete configuration

## 1. Schema Extraction

### From Annotate Gem Comments

If the model uses the `annotate` gem, schema information appears at the top:

```ruby
# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  name                   :string
#  role                   :integer          default("user")
#  active                 :boolean          default(TRUE)
#  metadata               :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
```

Parse this to extract:
- Column name
- Column type (bigint, string, integer, boolean, jsonb, datetime, etc.)
- Default value
- Not null constraint

### From db/schema.rb

If no annotation, read the table definition from `db/schema.rb`:

```ruby
create_table "users", force: :cascade do |t|
  t.string "email", default: "", null: false
  t.string "name"
  t.integer "role", default: 0
  t.boolean "active", default: true
  t.jsonb "metadata"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["email"], name: "index_users_on_email", unique: true
end
```

### Column Type Mapping

| DB Type | Ruby Type | Form Input | Table Display |
|---------|-----------|------------|---------------|
| `string` | String | `text_field` | `truncate(50)` |
| `text` | String | `text_area` | `truncate(100)` |
| `integer` | Integer | `number_field` | number |
| `bigint` | Integer | `number_field` | number |
| `float` | Float | `number_field step: 0.01` | `number_with_precision` |
| `decimal` | BigDecimal | `number_field step: 0.01` | `number_to_currency` |
| `boolean` | Boolean | `check_box` | Yes/No badge |
| `date` | Date | `date_field` | `strftime("%Y-%m-%d")` |
| `datetime` | DateTime | `datetime_local_field` | `strftime("%Y-%m-%d %H:%M")` |
| `time` | Time | `time_field` | `strftime("%H:%M")` |
| `json` / `jsonb` | Hash | `text_area` | Pretty JSON |
| `uuid` | String | `text_field` (readonly) | truncated UUID |
| `inet` | IPAddr | `text_field` | IP string |
| `array` | Array | `text_area` (comma-separated) | joined string |

## 2. Association Extraction

### belongs_to

```ruby
belongs_to :author, class_name: 'User'
belongs_to :category, optional: true
belongs_to :organization, -> { where(active: true) }
```

Extract:
- Association name
- Foreign key (default: `{name}_id`)
- Class name (if specified, else infer from association name)
- Optional flag (for form validation)

**Form:** `collection_select` with associated records
**Table:** Link to associated record

### has_many / has_one

```ruby
has_many :posts
has_many :comments, dependent: :destroy
has_one :profile
has_one :avatar, class_name: 'Image'
```

Extract:
- Association name
- Dependent option (for cascade behavior info)
- Class name

**Show page:** List of associated records with count
**Table:** Count badge (for has_many)

### has_and_belongs_to_many / has_many :through

```ruby
has_and_belongs_to_many :tags
has_many :taggings
has_many :tags, through: :taggings
```

Extract:
- Association name
- Join model (for has_many :through)

**Form:** Multiple select or checkboxes
**Table:** Comma-separated list (limited)

## 3. Enum Extraction

### Rails 6 Style

```ruby
enum status: { draft: 0, published: 1, archived: 2 }
enum role: [:user, :admin, :moderator]
```

### Rails 7+ Style

```ruby
enum :status, { draft: 0, published: 1, archived: 2 }
enum :role, [:user, :admin, :moderator], prefix: true
enum :visibility, { public: 0, private: 1 }, suffix: :level
```

Extract:
- Enum name
- Values (hash or array)
- Prefix/suffix options

**Form:** `select` with humanized options
**Table:** Colored badge based on value

## 4. Active Storage Detection

```ruby
has_one_attached :avatar
has_one_attached :document, dependent: :purge_later

has_many_attached :images
has_many_attached :files, service: :amazon
```

Extract:
- Attachment name
- Single vs multiple
- Service (if specified)

**Form:** `file_field` with preview
**Table:** Thumbnail (for images) or filename
**Show:** Full preview with download link

### Checking for Image

```ruby
# In view:
if record.avatar.attached? && record.avatar.image?
  image_tag record.avatar.variant(resize_to_limit: [100, 100])
end
```

## 5. Validation Extraction (for Required Fields)

```ruby
validates :email, presence: true, uniqueness: true
validates :name, presence: true, length: { maximum: 100 }
validates :age, numericality: { greater_than: 0 }
validates :terms, acceptance: true
```

Extract presence validations to mark fields as required in forms.

## 6. Ransackable Methods

Check if model already has ransackable configuration:

```ruby
def self.ransackable_attributes(auth_object = nil)
  ["email", "name", "status", "created_at"]
end

def self.ransackable_associations(auth_object = nil)
  ["author", "category"]
end

def self.ransortable_attributes(auth_object = nil)
  ["name", "created_at"]
end
```

If not present, generate based on:
- All columns except sensitive ones (password, tokens)
- belongs_to associations

## 7. Soft Delete Detection

### Paranoia Gem

```ruby
class User < ApplicationRecord
  acts_as_paranoid
end
```

Indicators:
- `acts_as_paranoid` in model
- `deleted_at` column in schema

### Discard Gem

```ruby
class User < ApplicationRecord
  include Discard::Model
end
```

Indicators:
- `include Discard::Model` in model
- `discarded_at` column in schema

## Model Analysis Output Structure

```ruby
{
  name: "User",
  table_name: "users",
  columns: [
    { name: "id", type: :bigint, primary: true },
    { name: "email", type: :string, null: false, default: "" },
    { name: "name", type: :string, null: true },
    { name: "role", type: :integer, enum: true, values: { user: 0, admin: 1 } },
    { name: "active", type: :boolean, default: true },
    { name: "metadata", type: :jsonb },
    { name: "created_at", type: :datetime, null: false },
    { name: "updated_at", type: :datetime, null: false }
  ],
  associations: {
    belongs_to: [
      { name: "organization", foreign_key: "organization_id", optional: false }
    ],
    has_many: [
      { name: "posts", dependent: :destroy }
    ],
    has_one: [
      { name: "profile" }
    ]
  },
  attachments: {
    single: ["avatar"],
    multiple: ["documents"]
  },
  enums: {
    role: { user: 0, admin: 1, moderator: 2 }
  },
  soft_delete: "discard",  # or "paranoia" or nil
  ransackable: {
    attributes: ["email", "name", "role", "created_at"],
    associations: ["organization"]
  },
  required_fields: ["email", "organization_id"]
}
```

## Implementation Notes

### Reading Model Files

```ruby
# Example: Reading a model file
model_content = File.read("app/models/user.rb")

# Extract class name
class_name = model_content.match(/class (\w+) < /)&.[](1)

# Extract associations
belongs_to_matches = model_content.scan(/belongs_to :(\w+)/)
has_many_matches = model_content.scan(/has_many :(\w+)/)

# Extract enums
enum_matches = model_content.scan(/enum[:\s]+(\w+)[,:\s]+(.+)/)

# Extract Active Storage
attachments = model_content.scan(/has_(?:one|many)_attached :(\w+)/)
```

### Reading Schema

```ruby
# Example: Reading schema.rb
schema_content = File.read("db/schema.rb")

# Extract table definition
table_match = schema_content.match(/create_table "users".*?end/m)
```
