module ApplicationHelper
  include Pagy::Frontend
  
  def full_title(page_title = "")
    base_title = "2yarn"
    if page_title.blank?
        base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def render_load_more(pagy)
    render "shared/load_more", pagy: pagy
  end
end
