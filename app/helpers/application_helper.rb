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
      "text-bg-success"
    when "failed"
      "text-bg-danger"
    when "deleted"
      "text-bg-warning"
    else
      "text-bg-secondary"
    end
  end

  def transfer_action_badge_class(transfer)
    case transfer.action
    when "export"
      "text-bg-info"
    when "withdraw"
      "text-bg-warning"
    else
      "text-bg-secondary"
    end
  end

  def transfer_status_badge_class(transfer)
    case transfer.status
    when "succeeded"
      "text-bg-success"
    when "failed"
      "text-bg-danger"
    when "pending"
      transfer.record.transferable? ? "text-bg-warning" : "text-bg-danger"
    else
      "text-bg-secondary"
    end
  end
end
