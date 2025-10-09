module FeedbacksHelper
  def feedback_badge_classes(feedback_type)
    # Base classes are consistent for all badges
    base_classes = "text-xs font-medium pi-2 pbe-half rounded"

    # Specific color classes based on the feedback type
    type_classes = {
      review:          "bg-blue-100 text-blue-800",
      bug_report:      "bg-red-100 text-red-800",
      feature_request: "bg-purple-100 text-purple-800",
      general:         "bg-slate-100 text-slate-700",
      other:           "bg-yellow-100 text-yellow-800"
    }.fetch(feedback_type.to_sym, "bg-gray-100 text-gray-700")

    "#{base_classes} #{type_classes}"
  end

  # Creates a filter link that merges params and adds an 'active' class if the filter is applied.
  def filter_link(text, param, value)
    # Check if the current filter is active
    is_active = params[param] == value.to_s

    # Define CSS classes
    base_classes = "btn btn--subtle text-xs"
    active_class = "bg-primary-container text-primary"
    inactive_class = "hover:bg-shade"
    
    # Combine classes
    link_classes = "#{base_classes} #{is_active ? active_class : inactive_class}"

    # Generate the link, merging the new filter param with existing ones (except for pagination)
    link_to text, feedbacks_path(request.query_parameters.except(:page).merge(param => value)), class: link_classes
  end
end