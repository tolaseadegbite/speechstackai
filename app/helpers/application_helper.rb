module ApplicationHelper
  include Pagy::Frontend
  
  # returns full title if present, else returns base title
  def full_title(page_title = "")
    base_title = "2yarn"
    if page_title.blank?
        base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # Renders a "Load More" button for paginated collections
  def render_load_more(pagy)
    render "shared/load_more", pagy: pagy
  end
end
