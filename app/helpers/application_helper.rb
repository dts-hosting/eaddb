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
end
