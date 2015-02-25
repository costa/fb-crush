class Friend < ActiveRecord::Base
  include SymmetryConcern
  include Notification

  belongs_to :ego, :class_name => 'User', :inverse_of => :friends
  belongs_to :user
  belongs_to :prev_crush_friend, :class_name => 'Friend'
  belongs_to :next_crush_friend, :class_name => 'Friend'

  scope :for_index, ->{includes :user}

  delegate :name, :to => :user
  delegate :pusher_channel, :to => :ego

  strip_attributes

  validates_presence_of :ego, :user
  validates_uniqueness_of :user, :scope => :ego

  before_update :timestamp_intention_mutuality, :if => :intention_changed?
  after_update :timestamp_intention_mutuality_symmetrical, :if => :mutual_intention_changed?
  before_save :set_crush_friends_before!
  after_save :set_crush_friends_after!
  after_destroy :remove_crush!


  def as_json(options=nil)
    {
      id: id,
      prev_crush_friend_id: prev_crush_friend_id,
      next_crush_friend_id: next_crush_friend_id,
      intention: intention,
      is_mutual_intention: mutual_intention?,
      user_name: user.name,
      user_pic_url:
        case user.provider
        when 'facebook'
          "//graph.facebook.com/#{user.uid}/picture?width=100&height=100"  # XXX 100px is in the CSS
        end
    }
  end

  class << self

    def find_by_facebook_uid(uid)
      includes(:user).where(users: {provider: 'facebook', uid: uid}).first
    end

    def first_crush
      where(prev_crush_friend_id: nil).where.not(next_crush_friend_id: nil).first
    end
    def last_crush
      where(next_crush_friend_id: nil).where.not(prev_crush_friend_id: nil).first
    end
    def after_crush
      friend = first_crush
      while friend.try(:intention) == 'love'
        friend = friend.next_crush_friend
      end
      friend
    end

  end


  def mutual_intention?
    !!mutual_intention_since
  end

  private

  # XXX crush_concern — must NOT set prev/next outside
  def set_crush_friends_before!
    if next_crush_friend.nil? && prev_crush_friend.nil?
      set_crush_last!
    elsif intention_changed?
      if intention
        set_crush_first!
      else
        set_crush_after_crush!
      end
    end
  end
  def set_crush_friends_after!
    if @_update_prev_with_id
      @_update_prev_with_id.update! next_crush_friend_id: id
      @_update_prev_with_id = nil
    end
    if @_update_next_with_id
      @_update_next_with_id.update! prev_crush_friend_id: id
      @_update_next_with_id = nil
    end
  end
  def set_crush_first!(first=nil)
    if (first ||= ego.friends.first_crush || ego.friends.first) && first != self
      remove_crush!
      self.prev_crush_friend_id, self.next_crush_friend_id = nil, first.id
      @_update_next_with_id = first
    end
  end
  def set_crush_last!(last=nil)
    if (last ||= ego.friends.last_crush || ego.friends.last) && last != self
      remove_crush!
      self.prev_crush_friend_id, self.next_crush_friend_id = last.id, nil
      @_update_prev_with_id = last
    end
  end
  def set_crush_after_crush!
    if (after = ego.friends.after_crush)
      if after.prev_crush_friend != self
        remove_crush!
        self.prev_crush_friend_id, self.next_crush_friend_id = after.prev_crush_friend_id, after.id
        @_update_prev_with_id = after.prev_crush_friend
        @_update_next_with_id = after
      end
    else
      set_crush_last!
    end
  end
  def remove_crush!
    prev_crush_friend.try :update!, next_crush_friend_id: next_crush_friend_id
    next_crush_friend.try :update!, prev_crush_friend_id: prev_crush_friend_id
  end

  # XXX mutuality_concern
  def timestamp_intention_mutuality
    if intention.present? && symmetrical_friend.intention == intention
      self.mutual_intention_since = Time.now
      self.different_intention_since = nil
    elsif symmetrical_friend.intention = intention_was
      self.different_intention_since = Time.now
      self.mutual_intention_since = nil
    end
  end
  def mutual_intention_changed?
    intention_changed? && mutual_intention_since_changed?
  end
  def timestamp_intention_mutuality_symmetrical
    symmetrical_friend.update! attributes.slice *%w[mutual_intention_since different_intention_since]
  end

end
