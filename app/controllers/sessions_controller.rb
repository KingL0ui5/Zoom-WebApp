class SessionsController < ApplicationController
  def new
  end
  
  def create 
    user = User.find_by(EmailAddress: params[:session][:EmailAddress])
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      redirect_to root_path
      #login and direct to users show page
    else
      flash[:danger] = 'Invalid email or password'
      render 'new'
    end
  end

  def destroy 
    log_out
    redirect_to root_path 
  end
end
