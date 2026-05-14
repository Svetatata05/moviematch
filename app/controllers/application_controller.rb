class ApplicationController < ActionController::Base
  before_action :log_request_info

  private

  def log_request_info
    Rails.logger.info "[REQUEST] #{request.method} #{request.fullpath} from #{request.remote_ip}"
  end
end