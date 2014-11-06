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

  before_update :set_mutual_timestamps, :if => :intention_changed?


  def as_json(options=nil)
    {
      id: id,
      intention: intention,
      is_mutual_intention: mutual_intention?,
      user_name: user.name,
      user_pic_url:
        case user.provider
        when 'facebook'
          "http://graph.facebook.com/#{user.uid}/picture?width=100&height=100"
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
    elsif symmetrical_friend.intention = intention_was
      self.different_intention_since = Time.now
      self.mutual_intention_since = nil
    end
    symmetrical_friend.update_attributes! attributes.slice *%w[mutual_intention_since different_intention_since]  if
      mutual_intention_since_changed?
  end

end
