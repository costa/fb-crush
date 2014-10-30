class Friend < ActiveRecord::Base
  include SymmetryConcern

  belongs_to :ego, :class_name => 'User', :inverse_of => :friends
  belongs_to :user

  scope :for_index, ->{order('updated_at DESC')}

  delegate :name, :to => :user

  strip_attributes

  validates_presence_of :ego
  validates_presence_of :user
  validates_uniqueness_of :user, :scope => :ego

  before_update :set_mutual_timestamps


  def as_json(options)
    {
      id: id,
      intention: intention,
      is_mutual_intention: mutual_intention?,
      user_name: user.name,
      user_pic_url:
        case user.provider
        when 'facebook'
          "http://graph.facebook.com/#{user.uid}/picture?type=square"
        end
    }
  end


  def self.find_by_facebook_uid(uid)
    where(users: {provider: 'facebook', uid: uid}).first
  end


  def mutual_intention?
    !!mutual_intention_since
  end

  private

  def set_mutual_timestamps
    if intention.present? && symmetrical_friend.intention == intention
      self.mutual_intention_since = Time.now
      self.different_intention_since = nil
    else
      self.different_intention_since = Time.now
      self.mutual_intention_since = nil
    end
  end

end
