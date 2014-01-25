class FriendDecorator < Draper::Decorator

  decorates_association :user
  delegate :id, :name, :intention, :mutual_intention?


  def update_notice
    h.t(
      if mutual_intention?
        'flash.friends.update.notice_mutual'
      elsif intention.blank?
        'flash.friends.update.notice_none'
      else
        'flash.friends.update.notice'
      end,
      name: name,
      intention: intention.presence && h.t(intention, scope: 'enumerize.friend.intention')
    )
  end

  def intention_class
    mutual_intention? ? "alert #{object.intention == 'love' ? 'alert-danger' : 'alert-info'}" : 'well'
  end

  def button_to_intention(which, options = {}, &block)
    h.button_to(
      {controller: :friends, action: :update, id: id, friend: {intention: which.to_s}},
      options.merge(
        :method => :put,
        :class => ['btn', options[:class].presence, object.intention.presence == which.presence ? 'active' : nil].compact.join(' ')
      ),
      &block
    )
  end

end
