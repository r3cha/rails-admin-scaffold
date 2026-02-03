# Tailwind CSS Class Reference

This file maps placeholder CSS classes to Tailwind CSS classes for admin panel generation.

## Layout Classes

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: body-class}` | `bg-gray-100 text-gray-900 antialiased` |
| `{CSS: sidebar-bg}` | `bg-gray-900 text-gray-100` |
| `{CSS: main-bg}` | `bg-gray-100` |
| `{CSS: md-hidden}` | `md:hidden` |
| `{CSS: hidden}` | `hidden` |

## Typography

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: page-title}` | `text-2xl font-bold text-gray-900` |
| `{CSS: page-subtitle}` | `text-gray-600 mt-1` |
| `{CSS: card-title}` | `text-lg font-semibold text-gray-900` |
| `{CSS: section-title}` | `text-base font-medium text-gray-900 mb-2` |
| `{CSS: text-muted}` | `text-gray-500` |
| `{CSS: text-sm}` | `text-sm` |
| `{CSS: text-xs}` | `text-xs` |
| `{CSS: text-danger}` | `text-red-600` |
| `{CSS: font-mono}` | `font-mono` |

## Page Header

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: page-header}` | `mb-6` |
| `{CSS: header-content}` | `flex flex-col sm:flex-row sm:items-center sm:justify-between` |
| `{CSS: header-actions}` | `mt-4 sm:mt-0 flex gap-2` |

## Header Bar

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: header}` | `bg-white shadow-sm border-b border-gray-200 sticky top-0 z-10` |
| `{CSS: header-container}` | `flex items-center justify-between h-16 px-4 sm:px-6` |
| `{CSS: header-title}` | `flex-1 min-w-0` |
| `{CSS: header-right}` | `flex items-center gap-4` |
| `{CSS: menu-toggle}` | `p-2 rounded-md text-gray-500 hover:text-gray-900 hover:bg-gray-100` |

## Sidebar

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: sidebar-container}` | `flex flex-col h-full` |
| `{CSS: sidebar-header}` | `flex items-center h-16 px-4 border-b border-gray-800` |
| `{CSS: sidebar-brand}` | `flex items-center gap-2` |
| `{CSS: brand-text}` | `text-xl font-bold text-white` |
| `{CSS: brand-badge}` | `text-xs bg-blue-600 text-white px-2 py-0.5 rounded` |
| `{CSS: sidebar-nav}` | `flex-1 px-2 py-4 space-y-1 overflow-y-auto` |
| `{CSS: sidebar-footer}` | `p-4 border-t border-gray-800` |
| `{CSS: nav-section}` | `mb-6` |
| `{CSS: nav-section-title}` | `px-3 text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2` |
| `{CSS: nav-link}` | `flex items-center gap-3 px-3 py-2 text-sm font-medium text-gray-300 rounded-md hover:bg-gray-800 hover:text-white transition-colors` |
| `{CSS: nav-link}.active` | `bg-gray-800 text-white` |
| `{CSS: nav-icon}` | `w-5 h-5 flex-shrink-0` |
| `{CSS: nav-badge}` | `ml-auto text-xs bg-gray-700 text-gray-300 px-2 py-0.5 rounded-full` |
| `{CSS: nav-empty}` | `px-3 text-sm text-gray-500` |

## Content Container

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: content-container}` | `p-4 sm:p-6` |
| `{CSS: footer}` | `p-4 border-t border-gray-200 text-center` |

## Cards

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: card}` | `bg-white rounded-lg shadow-sm border border-gray-200` |
| `{CSS: card-header}` | `px-4 py-3 border-b border-gray-200` |
| `{CSS: card-body}` | `p-4` |
| `{CSS: card-footer}` | `px-4 py-3 border-t border-gray-200 bg-gray-50` |
| `{CSS: p-0}` | `p-0` |

## Buttons

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: btn-primary}` | `inline-flex items-center px-4 py-2 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors` |
| `{CSS: btn-secondary}` | `inline-flex items-center px-4 py-2 bg-gray-600 text-white font-medium rounded-md hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-colors` |
| `{CSS: btn-success}` | `inline-flex items-center px-4 py-2 bg-green-600 text-white font-medium rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition-colors` |
| `{CSS: btn-danger}` | `inline-flex items-center px-4 py-2 bg-red-600 text-white font-medium rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 transition-colors` |
| `{CSS: btn-warning}` | `inline-flex items-center px-4 py-2 bg-yellow-500 text-white font-medium rounded-md hover:bg-yellow-600 focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2 transition-colors` |
| `{CSS: btn-outline}` | `inline-flex items-center px-4 py-2 border border-gray-300 text-gray-700 font-medium rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors` |
| `{CSS: btn-ghost}` | `inline-flex items-center px-4 py-2 text-gray-600 font-medium hover:text-gray-900 hover:bg-gray-100 rounded-md transition-colors` |
| `{CSS: btn-sm}` | `px-3 py-1.5 text-sm` |
| `{CSS: btn-group}` | `flex items-center gap-2` |

## Forms

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: form}` | `space-y-6` |
| `{CSS: form-grid}` | `grid grid-cols-1 md:grid-cols-2 gap-6` |
| `{CSS: form-group}` | `space-y-1` |
| `{CSS: form-group-full}` | `space-y-1 md:col-span-2` |
| `{CSS: form-group-inline}` | `flex items-center gap-2` |
| `{CSS: label}` | `block text-sm font-medium text-gray-700` |
| `{CSS: input}` | `block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm` |
| `{CSS: textarea}` | `block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm` |
| `{CSS: select}` | `block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm` |
| `{CSS: checkbox}` | `h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500` |
| `{CSS: checkbox-wrapper}` | `flex items-center gap-2` |
| `{CSS: checkbox-label}` | `text-sm text-gray-700` |
| `{CSS: file-input}` | `block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100` |
| `{CSS: form-hint}` | `text-xs text-gray-500 mt-1` |
| `{CSS: form-actions}` | `flex items-center gap-4 pt-4 border-t border-gray-200` |

## Tables

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: table-responsive}` | `overflow-x-auto` |
| `{CSS: table}` | `min-w-full divide-y divide-gray-200` |
| `{CSS: table-header}` | `bg-gray-50` |
| `{CSS: table-body}` | `bg-white divide-y divide-gray-200` |
| `{CSS: th}` | `px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider` |
| `{CSS: th-checkbox}` | `w-12` |
| `{CSS: th-actions}` | `text-right` |
| `{CSS: tr}` | `hover:bg-gray-50 transition-colors` |
| `{CSS: tr-deleted}` | `bg-red-50 opacity-75` |
| `{CSS: td}` | `px-4 py-3 text-sm text-gray-900 whitespace-nowrap` |
| `{CSS: td-actions}` | `text-right` |

## Badges

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: badge}` | `inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium` |
| `{CSS: badge-success}` | `bg-green-100 text-green-800` |
| `{CSS: badge-danger}` | `bg-red-100 text-red-800` |
| `{CSS: badge-warning}` | `bg-yellow-100 text-yellow-800` |
| `{CSS: badge-info}` | `bg-blue-100 text-blue-800` |
| `{CSS: badge-secondary}` | `bg-gray-100 text-gray-800` |

## Alerts

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: alert}` | `rounded-md p-4` |
| `{CSS: alert-success}` | `bg-green-50 text-green-800 border border-green-200` |
| `{CSS: alert-danger}` | `bg-red-50 text-red-800 border border-red-200` |
| `{CSS: alert-warning}` | `bg-yellow-50 text-yellow-800 border border-yellow-200` |
| `{CSS: alert-info}` | `bg-blue-50 text-blue-800 border border-blue-200` |
| `{CSS: alert-content}` | `flex items-start` |
| `{CSS: alert-icon}` | `w-5 h-5 mr-3 flex-shrink-0` |
| `{CSS: alert-message}` | `flex-1` |
| `{CSS: alert-title}` | `font-medium mb-2` |
| `{CSS: alert-dismiss}` | `ml-auto -mr-1 -mt-1 p-1 rounded hover:bg-black/5` |
| `{CSS: alert-dismissible}` | `relative pr-10` |
| `{CSS: error-list}` | `list-disc list-inside mt-2 text-sm` |

## Description Lists

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: description-list}` | `divide-y divide-gray-200` |
| `{CSS: dl-row}` | `py-3 sm:grid sm:grid-cols-3 sm:gap-4` |
| `{CSS: dl-term}` | `text-sm font-medium text-gray-500` |
| `{CSS: dl-detail}` | `mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2` |

## Stats Cards (Dashboard)

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: stats-grid}` | `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4` |
| `{CSS: stat-card}` | `bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden` |
| `{CSS: stat-card-body}` | `p-4 flex items-start` |
| `{CSS: stat-card-footer}` | `px-4 py-2 bg-gray-50 border-t border-gray-200` |
| `{CSS: stat-icon-container}` | `p-3 rounded-lg bg-blue-100 text-blue-600` |
| `{CSS: stat-icon}` | `w-6 h-6` |
| `{CSS: stat-content}` | `ml-4` |
| `{CSS: stat-label}` | `text-sm font-medium text-gray-500` |
| `{CSS: stat-value}` | `text-2xl font-bold text-gray-900` |
| `{CSS: stat-details}` | `mt-1 flex gap-4 text-xs text-gray-500` |
| `{CSS: stat-detail-item}` | `` |
| `{CSS: stat-detail-value}` | `font-medium text-gray-900` |
| `{CSS: stat-link}` | `text-sm text-blue-600 hover:text-blue-800` |

## Activity Feed

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: activity-feed}` | `space-y-4` |
| `{CSS: activity-item}` | `flex items-start gap-3` |
| `{CSS: activity-icon}` | `p-2 rounded-full bg-gray-100 text-gray-600` |
| `{CSS: activity-content}` | `flex-1 min-w-0` |
| `{CSS: activity-text}` | `text-sm text-gray-900` |
| `{CSS: activity-model}` | `font-medium` |
| `{CSS: activity-action}` | `text-gray-500` |
| `{CSS: activity-time}` | `text-xs text-gray-500` |

## Filters

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: filter-form}` | `space-y-4` |
| `{CSS: filter-grid}` | `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4` |
| `{CSS: filter-row}` | `flex flex-wrap items-center gap-4` |
| `{CSS: filter-actions}` | `flex items-center gap-2 pt-4` |
| `{CSS: filter-bar}` | `border border-gray-200 rounded-lg` |
| `{CSS: filter-bar-header}` | `flex items-center justify-between px-4 py-2 bg-gray-50` |
| `{CSS: filter-bar-actions}` | `flex items-center gap-2` |
| `{CSS: filter-toggle}` | `flex items-center gap-2 text-sm font-medium text-gray-700` |
| `{CSS: filter-count}` | `text-gray-500` |
| `{CSS: filter-content}` | `p-4 border-t border-gray-200` |
| `{CSS: chevron-icon}` | `w-4 h-4 transition-transform` |

## Pagination

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: pagination-container}` | `flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4` |
| `{CSS: pagination-info}` | `text-sm text-gray-700` |
| `{CSS: pagination-nav}` | `flex items-center gap-1` |

## Images

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: img-thumbnail}` | `rounded-md border border-gray-200` |
| `{CSS: img-thumbnail-sm}` | `w-10 h-10 rounded object-cover border border-gray-200` |
| `{CSS: image-grid}` | `grid grid-cols-4 gap-2` |
| `{CSS: attachment-preview}` | `flex items-center gap-4` |
| `{CSS: attachment-grid}` | `grid grid-cols-4 sm:grid-cols-6 gap-2` |
| `{CSS: attachment-item}` | `relative` |

## Utilities

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: flex-between}` | `flex items-center justify-between` |
| `{CSS: flex-center}` | `flex items-center` |
| `{CSS: gap-2}` | `gap-2` |
| `{CSS: gap-4}` | `gap-4` |
| `{CSS: mb-2}` | `mb-2` |
| `{CSS: mb-4}` | `mb-4` |
| `{CSS: mt-2}` | `mt-2` |
| `{CSS: mt-4}` | `mt-4` |
| `{CSS: mt-6}` | `mt-6` |
| `{CSS: ml-4}` | `ml-4` |
| `{CSS: col-span-full}` | `col-span-full` |
| `{CSS: grid-2}` | `grid grid-cols-1 lg:grid-cols-2 gap-6` |
| `{CSS: icon}` | `w-5 h-5` |
| `{CSS: icon-sm}` | `w-4 h-4` |
| `{CSS: link}` | `text-blue-600 hover:text-blue-800 hover:underline` |
| `{CSS: code-block}` | `bg-gray-100 rounded p-3 text-sm font-mono overflow-x-auto` |
| `{CSS: empty-state}` | `text-center py-12` |
| `{CSS: inline-form}` | `inline` |
| `{CSS: action-bar}` | `flex items-center gap-4` |
| `{CSS: list}` | `space-y-2` |
| `{CSS: list-item}` | `flex items-center justify-between` |

## Breadcrumbs

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: breadcrumb}` | `flex items-center text-sm text-gray-500 mb-2` |
| `{CSS: breadcrumb-link}` | `hover:text-gray-700` |
| `{CSS: breadcrumb-separator}` | `mx-2` |
| `{CSS: breadcrumb-current}` | `text-gray-900 font-medium` |

## Quick Actions

| Placeholder | Tailwind Classes |
|-------------|------------------|
| `{CSS: quick-actions-grid}` | `grid grid-cols-2 sm:grid-cols-4 gap-4` |
| `{CSS: quick-action}` | `flex flex-col items-center gap-2 p-4 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors` |
| `{CSS: quick-action-icon}` | `w-8 h-8 text-gray-600` |
