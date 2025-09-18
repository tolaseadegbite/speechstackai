class Authentications::EventsController < DashboardController
  def index
    @events = Current.user.events.order(created_at: :desc)
  end
end
