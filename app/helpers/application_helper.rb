module ApplicationHelper
  include Filterable
  include Pagy::Frontend

  def safe_external_link(url, link_text = nil)
    link_text ||= url
    if url.to_s.match?(/\A(http|https):\/\//)
      link_to(link_text, url, target: "_blank", rel: "noopener noreferrer")
    else
      url
    end
  end

  def status_badge_class(type)
    case type.status
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

  def transfer_status_badge_class(transfer)
    case transfer.status
    when "succeeded"
      "bg-success"
    when "failed"
      "bg-danger"
    when "pending"
      transfer.record.ok_to_run? ? "bg-warning" : "bg-danger"
    else
      "bg-secondary"
    end
  end
end
