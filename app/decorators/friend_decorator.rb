class FriendDecorator < Draper::Decorator
  decorates_association :user
  delegate :id

end
