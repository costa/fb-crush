class UserAuthenticatedConstraint
  def matches?(request)
    request.session[:user_id].present?
  end
end
