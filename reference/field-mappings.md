# Field Type Mappings Reference

This document defines how database column types map to form inputs and table displays.

## Complete Field Mapping Table

| DB Type | Form Input | Table Display | Filter Input | Notes |
|---------|------------|---------------|--------------|-------|
| `string` | `text_field` | `truncate(50)` | `text_field` + `_cont` | Standard text input |
| `text` | `text_area rows: 5` | `truncate(100)` | `text_field` + `_cont` | Multi-line text |
| `integer` | `number_field` | number | `number_field` + `_eq` | Whole numbers |
| `bigint` | `number_field` | number | `number_field` + `_eq` | Large integers |
| `float` | `number_field step: "any"` | `number_with_precision(2)` | range inputs | Floating point |
| `decimal` | `number_field step: 0.01` | `number_to_currency` | range inputs | Currency/precision |
| `boolean` | `check_box` | Yes/No badge | `select` true/false | Boolean toggle |
| `date` | `date_field` | `strftime("%Y-%m-%d")` | date range | Date picker |
| `datetime` | `datetime_local_field` | `strftime("%Y-%m-%d %H:%M")` | datetime range | DateTime picker |
| `time` | `time_field` | `strftime("%H:%M")` | time range | Time only |
| `json` | `text_area` + JSON | Pretty JSON (collapsed) | N/A | JSON editor |
| `jsonb` | `text_area` + JSON | Pretty JSON (collapsed) | specific keys | PostgreSQL JSON |
| `uuid` | `text_field readonly` | truncated | `text_field` + `_eq` | UUID display |
| `inet` | `text_field` | IP string | `text_field` + `_eq` | IP addresses |
| `cidr` | `text_field` | CIDR string | `text_field` + `_eq` | Network ranges |
| `macaddr` | `text_field` | MAC string | `text_field` + `_eq` | MAC addresses |
| `hstore` | `text_area` | key-value list | specific keys | PostgreSQL hstore |
| `array` | `text_area` | comma-separated | `_contains` | PostgreSQL arrays |
| `enum` (DB) | `select` | badge | `select` + `_eq` | PostgreSQL enum |
| `point` | 2x `number_field` | coordinates | N/A | Geographic point |
| `references` | `collection_select` | `link_to` associated | `select` + `_eq` | Foreign key |
| `attachment` | `file_field` | thumbnail/link | N/A | Active Storage |

## Form Input Details

### String Fields

```erb
<%= f.text_field :name, class: "input", maxlength: 255 %>
```

For email:
```erb
<%= f.email_field :email, class: "input" %>
```

For URL:
```erb
<%= f.url_field :website, class: "input" %>
```

For phone:
```erb
<%= f.telephone_field :phone, class: "input" %>
```

### Text Fields

```erb
<%= f.text_area :description, class: "textarea", rows: 5 %>
```

For rich text (if Action Text):
```erb
<%= f.rich_text_area :content %>
```

### Number Fields

Integer:
```erb
<%= f.number_field :quantity, class: "input", min: 0, step: 1 %>
```

Decimal/Currency:
```erb
<%= f.number_field :price, class: "input", min: 0, step: 0.01 %>
```

Float:
```erb
<%= f.number_field :rating, class: "input", min: 0, max: 5, step: "any" %>
```

### Boolean Fields

```erb
<div class="checkbox-wrapper">
  <%= f.check_box :active, class: "checkbox" %>
  <%= f.label :active, class: "checkbox-label" %>
</div>
```

Or as switch:
```erb
<label class="switch">
  <%= f.check_box :active %>
  <span class="slider"></span>
</label>
```

### Date/Time Fields

Date:
```erb
<%= f.date_field :published_on, class: "input" %>
```

DateTime:
```erb
<%= f.datetime_local_field :scheduled_at, class: "input" %>
```

Time:
```erb
<%= f.time_field :start_time, class: "input" %>
```

### JSON/JSONB Fields

```erb
<%= f.text_area :metadata,
                value: @record.metadata.present? ? JSON.pretty_generate(@record.metadata) : "",
                class: "textarea font-mono",
                rows: 8,
                data: { controller: "json-editor" } %>
<p class="form-hint">Enter valid JSON format</p>
```

### Enum Fields

```erb
<%= f.select :status,
             Model.statuses.keys.map { |s| [s.humanize, s] },
             { include_blank: "Select status..." },
             class: "select" %>
```

With custom labels:
```erb
<%= f.select :status,
             Model.statuses.keys.map { |s| [I18n.t("models.status.#{s}"), s] },
             { include_blank: "Select..." },
             class: "select" %>
```

### Association Fields

belongs_to (single select):
```erb
<%= f.collection_select :author_id,
                        User.order(:name),
                        :id, :name,
                        { include_blank: "Select author..." },
                        class: "select" %>
```

has_many/HABTM (multiple select):
```erb
<%= f.collection_select :tag_ids,
                        Tag.order(:name),
                        :id, :name,
                        {},
                        { multiple: true, class: "select" } %>
```

Or with checkboxes:
```erb
<%= f.collection_check_boxes :tag_ids, Tag.order(:name), :id, :name do |b| %>
  <div class="checkbox-wrapper">
    <%= b.check_box class: "checkbox" %>
    <%= b.label class: "checkbox-label" %>
  </div>
<% end %>
```

### File Fields (Active Storage)

Single attachment:
```erb
<% if @record.avatar.attached? %>
  <div class="attachment-preview">
    <% if @record.avatar.image? %>
      <%= image_tag @record.avatar.variant(resize_to_limit: [100, 100]) %>
    <% else %>
      Current: <%= @record.avatar.filename %>
    <% end %>
    <label class="checkbox-wrapper">
      <%= f.check_box :remove_avatar, {}, "1", "0" %>
      <span>Remove file</span>
    </label>
  </div>
<% end %>
<%= f.file_field :avatar, class: "file-input", accept: "image/*" %>
```

Multiple attachments:
```erb
<% if @record.images.attached? %>
  <div class="attachment-grid">
    <% @record.images.each do |image| %>
      <div class="attachment-item">
        <%= image_tag image.variant(resize_to_limit: [80, 80]) %>
      </div>
    <% end %>
  </div>
<% end %>
<%= f.file_field :images, multiple: true, class: "file-input", accept: "image/*" %>
```

## Table Display Details

### String/Text

```erb
<%= truncate(record.name, length: 50) %>
```

With tooltip for full text:
```erb
<span title="<%= record.description %>">
  <%= truncate(record.description, length: 100) %>
</span>
```

### Numbers

Integer:
```erb
<%= number_with_delimiter(record.quantity) %>
```

Currency:
```erb
<%= number_to_currency(record.price) %>
```

Percentage:
```erb
<%= number_to_percentage(record.rate, precision: 1) %>
```

### Boolean

Badge style:
```erb
<span class="badge <%= record.active? ? 'badge-success' : 'badge-secondary' %>">
  <%= record.active? ? 'Yes' : 'No' %>
</span>
```

Icon style:
```erb
<% if record.active? %>
  <svg class="icon text-success"><!-- check icon --></svg>
<% else %>
  <svg class="icon text-muted"><!-- x icon --></svg>
<% end %>
```

### Date/Time

Date:
```erb
<%= record.published_on&.strftime("%Y-%m-%d") %>
```

DateTime:
```erb
<%= record.created_at&.strftime("%Y-%m-%d %H:%M") %>
```

Relative:
```erb
<%= time_ago_in_words(record.created_at) %> ago
```

### Enum

Colored badge:
```erb
<%
  badge_class = case record.status
                when "draft" then "badge-secondary"
                when "published" then "badge-success"
                when "archived" then "badge-warning"
                else "badge-info"
                end
%>
<span class="badge <%= badge_class %>">
  <%= record.status.humanize %>
</span>
```

### JSON/JSONB

Collapsed with expand:
```erb
<% if record.metadata.present? %>
  <details>
    <summary class="link">View JSON</summary>
    <pre class="code-block"><%= JSON.pretty_generate(record.metadata) %></pre>
  </details>
<% else %>
  <span class="text-muted">-</span>
<% end %>
```

Or key-value display:
```erb
<% if record.metadata.present? %>
  <dl class="inline-dl">
    <% record.metadata.each do |key, value| %>
      <dt><%= key %>:</dt>
      <dd><%= value %></dd>
    <% end %>
  </dl>
<% end %>
```

### Associations

belongs_to:
```erb
<% if record.author %>
  <%= link_to record.author.name, admin_user_path(record.author) %>
<% else %>
  <span class="text-muted">-</span>
<% end %>
```

has_many (count badge):
```erb
<span class="badge badge-info">
  <%= record.comments.count %> comments
</span>
```

### Attachments

Single image:
```erb
<% if record.avatar.attached? && record.avatar.image? %>
  <%= image_tag record.avatar.variant(resize_to_limit: [40, 40]), class: "img-thumbnail-sm" %>
<% elsif record.avatar.attached? %>
  <%= link_to record.avatar.filename, rails_blob_path(record.avatar) %>
<% else %>
  <span class="text-muted">-</span>
<% end %>
```

Multiple (count):
```erb
<% if record.images.attached? %>
  <span class="badge badge-info"><%= record.images.count %> images</span>
<% else %>
  <span class="text-muted">-</span>
<% end %>
```

## Filter Input Details

### Text Search (Ransack)

```erb
<%= f.search_field :name_or_email_cont, placeholder: "Search..." %>
```

### Exact Match

```erb
<%= f.text_field :id_eq %>
```

### Range Filters

Date range:
```erb
<%= f.date_field :created_at_gteq, placeholder: "From" %>
<%= f.date_field :created_at_lteq, placeholder: "To" %>
```

Number range:
```erb
<%= f.number_field :price_gteq, placeholder: "Min" %>
<%= f.number_field :price_lteq, placeholder: "Max" %>
```

### Boolean Filter

```erb
<%= f.select :active_eq,
             [["Yes", true], ["No", false]],
             { include_blank: "All" } %>
```

### Enum Filter

```erb
<%= f.select :status_eq,
             Model.statuses.keys.map { |s| [s.humanize, s] },
             { include_blank: "All statuses" } %>
```

### Association Filter

```erb
<%= f.collection_select :author_id_eq,
                        User.order(:name),
                        :id, :name,
                        { include_blank: "All authors" } %>
```

## Hidden/Excluded Fields

Always hide in forms:
- `id`
- `created_at`
- `updated_at`
- `encrypted_password`
- `reset_password_token`
- `confirmation_token`
- `unlock_token`
- `remember_token`
- `authentication_token`
- `password_digest`
- `password_salt`

Consider hiding:
- `confirmation_sent_at`
- `confirmed_at`
- `current_sign_in_at`
- `last_sign_in_at`
- `current_sign_in_ip`
- `last_sign_in_ip`
- `sign_in_count`
- `failed_attempts`
- `locked_at`
