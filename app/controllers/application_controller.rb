class ApplicationController < ActionController::Base
  before_action :set_language
  before_action :log_request_info
  helper_method :current_user, :logged_in?, :english?, :language_param

  private

  def set_language
    session[:language] = "ua"
  end

  def english?
    false
  end

  def language_param(language)
    request.query_parameters.merge(lang: language)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Будь ласка, увійдіть в систему"
    end
  end

  def require_admin
    unless logged_in? && current_user.admin?
      redirect_to movies_path, alert: "Доступ тільки для адміністратора"
    end
  end

  def save_uploaded_poster(upload)
    return nil if upload.blank?
    return nil unless upload.content_type.to_s.start_with?("image/")

    extension = File.extname(upload.original_filename).presence || ".jpg"
    filename = "#{SecureRandom.hex(12)}#{extension.downcase}"
    relative_path = "uploads/custom_posters/#{filename}"
    absolute_path = Rails.root.join("public", relative_path)

    FileUtils.mkdir_p(absolute_path.dirname)
    File.binwrite(absolute_path, upload.read)
    "/#{relative_path}"
  end

  def destroy_orphan_manual_movie(movie)
    return unless movie.manual? && movie.user == current_user
    return if current_user.watchlists.exists?(movie: movie)
    return if current_user.movie_reactions.exists?(movie: movie)

    movie.destroy
  end

  def log_request_info
    Rails.logger.info "[REQUEST] #{request.method} #{request.fullpath} from #{request.remote_ip}"
  end
end
