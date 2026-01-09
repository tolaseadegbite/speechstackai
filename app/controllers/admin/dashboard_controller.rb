module Admin
  class DashboardController < BaseController
    def index
      # Calculate stats for the admin view
      @total_users = User.count
      @total_clips = GeneratedAudioClip.count
      @total_credits = User.sum(:credits)

      # Fetch recent data
      @latest_users = User.order(created_at: :desc).limit(5)
      @latest_clips = GeneratedAudioClip.includes(:user).order(created_at: :desc).limit(5)
    end
  end
end
