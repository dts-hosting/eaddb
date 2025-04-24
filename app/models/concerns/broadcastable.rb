module Broadcastable
  extend ActiveSupport::Concern
  include ActionView::RecordIdentifier

  included do
    broadcasts_refreshes
  end

  def broadcast_message(message)
    Turbo::StreamsChannel.broadcast_update_to(
      self,
      target: "#{dom_id(self)}_message",
      html: render_message(message)
    )
  end

  private

  def resolve_base_type
    self.class.superclass.name.downcase
  end

  def render_message(message)
    ApplicationController.renderer.render(
      partial: "shared/message",
      locals: {
        message: message,
        timestamp: Time.current.strftime("%H:%M:%S")
      }
    )
  end
end
