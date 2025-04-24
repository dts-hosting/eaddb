module ApplicationHelper
  include Filterable
  include Pagy::Frontend

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

  def safe_external_link(url, link_text = nil)
    link_text ||= url
    if url.to_s.match?(/\A(http|https):\/\//)
      link_to(link_text, url, target: "_blank", rel: "noopener noreferrer")
    else
      url
    end
  end

  def transfer_status_badge_class(status)
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
