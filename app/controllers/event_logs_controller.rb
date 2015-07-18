class EventLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @event_logs = current_user.event_logs
  end
end
