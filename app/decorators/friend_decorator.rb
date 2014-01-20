class FriendDecorator < Draper::Decorator
  decorates_association :user
  delegate :id, :intention, :mutual_intention?

end
