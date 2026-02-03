# Template: Dashboard Controller
#
# Variables to replace:
#   {NAMESPACE} - Module name (e.g., Admin)
#   {namespace} - Lowercase namespace (e.g., admin)
#   {MODELS} - Array of model names for stats
#
# Usage: Copy this template and customize with actual models.

module {NAMESPACE}
  class DashboardController < BaseController
    def index
      @stats = gather_stats
      @recent_activity = gather_recent_activity
    end

    private

    def gather_stats
      # Generate stat cards for each model
      # Replace with actual models:
      {
        # users: {
        #   count: User.count,
        #   today: User.where("created_at >= ?", Time.current.beginning_of_day).count,
        #   this_week: User.where("created_at >= ?", 1.week.ago).count,
        #   this_month: User.where("created_at >= ?", 1.month.ago).count
        # },
        # posts: {
        #   count: Post.count,
        #   today: Post.where("created_at >= ?", Time.current.beginning_of_day).count,
        #   this_week: Post.where("created_at >= ?", 1.week.ago).count,
        #   this_month: Post.where("created_at >= ?", 1.month.ago).count
        # }
      }
    end

    def gather_recent_activity
      # Combine recent records from multiple models
      # Replace with actual models:
      activity = []

      # Example:
      # activity += User.order(created_at: :desc).limit(5).map do |user|
      #   { model: "User", record: user, action: "created", time: user.created_at }
      # end
      #
      # activity += Post.order(updated_at: :desc).limit(5).map do |post|
      #   { model: "Post", record: post, action: "updated", time: post.updated_at }
      # end

      activity.sort_by { |a| -a[:time].to_i }.first(10)
    end
  end
end
