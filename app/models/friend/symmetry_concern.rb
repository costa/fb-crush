module Friend::SymmetryConcern
  extend ActiveSupport::Concern

  included do

    attr_writer :symmetrical

    after_create :create_symmetrical, :unless => :symmetrical
    after_destroy :destroy_symmetrical, :unless => :symmetrical

  end

  def symmetrical_friend
    @symmetrical_friend ||= Friend.where(ego: user, user: ego).first
  end

  private

  def symmetrical; @symmetrical; end

  def create_symmetrical
    @symmetrical_friend = Friend.create! ego: user, user: ego, symmetrical: self
  end

  def destroy_symmetrical
    symmetrical_friend.symmetrical = self
    symmetrical_friend.destroy
  end

end
