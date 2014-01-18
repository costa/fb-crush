class UserDecorator < Draper::Decorator
  delegate_all

  def picture(size = nil)
    h.image_tag facebook_me.picture(size)
  end

  private

  def facebook_me
    @facebook_me ||= FbGraph::User.me(h.session[:facebook_access_token]).fetch
  end
end
