class Friend < ActiveRecord::Base
  include SymmetryConcern

  belongs_to :ego, :class_name => 'User', :inverse_of => :friends
  belongs_to :user

  scope :for_index, ->{order('updated_at DESC')}

  strip_attributes

  validates_presence_of :ego
  validates_presence_of :user
  validates_uniqueness_of :user, :scope => :ego

  def self.find_by_facebook_uid(uid)
    where(users: {provider: 'facebook', uid: uid}).first
  end

  def mutual_intention?
    intention.present? && symmetrical_friend.intention == intention
  end
end
