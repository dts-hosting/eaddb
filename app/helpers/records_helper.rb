module RecordsHelper
  def record_status_badge_class(status)
    case status
    when "active"
      "bg-success"
    when "failed"
      "bg-danger"
    when "deleted"
      "bg-warning"
    else
      "bg-secondary"
    end
  end
end
