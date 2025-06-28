class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :resume_session
  before_action :set_scout_context

  def set_scout_context
    ScoutApm::Context.add_user(id: Current.user.id) if Current.user.is_a?(User)
  end
end
