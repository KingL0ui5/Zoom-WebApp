module SessionsHelper
  def log_in(user) #logs in user 
    session[:user_EmployeeID] = user.id
  end
  
  def current_user #gets current user 
    if session[:user_EmployeeID]
      @current_user ||= User.find_by(EmployeeID: session[:user_EmployeeID])
    end  
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  def log_out
    session.delete(:user_EmployeeID)
    @current_user = nil
  end   
end
