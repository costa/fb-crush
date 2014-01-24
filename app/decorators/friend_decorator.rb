class FriendDecorator < Draper::Decorator
  decorates_association :user
  delegate :id, :intention, :mutual_intention?

  def intention_class
    mutual_intention? ? "alert #{intention == 'love' ? 'alert-danger' : 'alert-info'}" : 'well'
  end

  def button_to_intention(which, options = {}, &block)
    h.button_to(
      {controller: :friends, action: :update, id: id, friend: {intention: which.to_s}},
      options.merge(
        :method => :put,
        :class => ['btn', options[:class].presence, intention.presence == which.presence ? 'active' : nil].compact.join(' ')
      ),
      &block
    )
  end
end
