class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to movies_path, alert: "Ви вже увійшли. Спочатку вийдіть з акаунту."
    end
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to movies_path, notice: "Ласкаво просимо, #{user.name}!"
    else
      flash.now[:alert] = "Невірний email або пароль"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Ви вийшли з системи"
  end
end