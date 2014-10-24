class UserDecorator < Draper::Decorator

  decorates_finders
  delegate *%i[name friends_fetched_at friends fetch_friends]

  def badge
    h.capture_haml do
      h.haml_tag :div, picture(:square), class: 'picture inline-middle'
      h.haml_tag :big, name, class: 'name inline-middle'
    end
  end

  def picture(size = nil)
    h.image_tag "http://graph.facebook.com/#{object.uid}/picture" + (size ? "?type=#{size}" : '')
  end

end
