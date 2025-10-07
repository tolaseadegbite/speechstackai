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
end