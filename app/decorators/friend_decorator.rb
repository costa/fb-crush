class FriendDecorator < Draper::Decorator
  decorates_association :user
  delegate :id, :name, :mutual_intention?


  def intention_t
    h.t(object.intention.presence || 'none', scope: 'enumerize.friend.intention')
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
