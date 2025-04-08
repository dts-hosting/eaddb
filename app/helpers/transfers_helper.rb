module TransfersHelper
  def status_badge_class(status)
    case status
    when "succeeded"
      "bg-success"
    when "failed"
      "bg-danger"
    when "pending"
      "bg-warning"
    else
      "bg-secondary"
    end
  end
end
