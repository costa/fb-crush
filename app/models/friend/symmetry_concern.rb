module Friend::SymmetryConcern
  extend ActiveSupport::Concern

  included do

    attr_writer :symmetrical

    after_create :create_symmetrical, :unless => :symmetrical
    after_destroy :destroy_symmetrical, :unless => :symmetrical

  end

  def symmetrical_friend
    @symmetrical_friend ||= user.friends.find_or_initialize_by user: ego
  end

  private

  def symmetrical; @symmetrical; end

  def create_symmetrical
    symmetrical_friend.symmetrical = self
    symmetrical_friend.save!
  end

  def destroy_symmetrical
    symmetrical_friend.symmetrical = self
    symmetrical_friend.destroy
  end

end
