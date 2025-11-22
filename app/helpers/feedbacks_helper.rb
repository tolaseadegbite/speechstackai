module FeedbacksHelper
  def dropdown_filter_item(text, param_key, param_value)
    is_active = params[param_key].to_s == param_value.to_s
    active_class = is_active ? "bg-primary-container" : ""

    link_to text,
            feedbacks_path(request.query_parameters.except(:page).merge(param_key => param_value)),
            class: "btn menu__item w-full text-left #{active_class}",
            role: "menuitem"
  end

  def dropdown_all_filter_item(text, param_to_clear)
    is_active = !params[param_to_clear].present?
    active_class = is_active ? "bg-primary-container" : ""

    link_to text,
            feedbacks_path(request.query_parameters.except(:page, param_to_clear)),
            class: "btn menu__item w-full text-left #{active_class}",
            role: "menuitem"
  end

  def feedback_badge_classes(feedback_type)
    base_classes = "text-xs font-medium pi-2 pbe-half rounded"

    type_classes = {
      review:          "bg-blue-100 text-blue-800",
      bug_report:      "bg-red-100 text-red-800",
      feature_request: "bg-purple-100 text-purple-800",
      general:         "bg-slate-100 text-slate-700",
      other:           "bg-yellow-100 text-yellow-800"
    }.fetch(feedback_type.to_sym, "bg-gray-100 text-gray-700")

    "#{base_classes} #{type_classes}"
  end

  def filter_link(text, param, value)
    is_active = params[param] == value.to_s

    base_classes = "btn btn--subtle text-xs"
    active_class = "bg-primary-container text-primary"
    inactive_class = "hover:bg-shade"
    
    link_classes = "#{base_classes} #{is_active ? active_class : inactive_class}"

    link_to text, feedbacks_path(request.query_parameters.except(:page).merge(param => value)), class: link_classes
  end
end