class UserDecorator < Draper::Decorator
  decorates_finders
  delegate :name, :facebook_setup, :uid, :facebook_fetched_at, :friends

  def badge
    h.capture_haml do
      h.haml_tag :div, picture(:square), class: 'picture inline-middle'
      h.haml_tag :big, name, class: 'name inline-middle'
    end
  end

  def picture(size = nil)
    h.image_tag "http://graph.facebook.com/#{uid}/picture" + (size ? "?type=#{size}" : '')
  end

  def facebook_me
    object.facebook_setup h.session[:facebook_access_token]
    object.facebook_me
  end
end
