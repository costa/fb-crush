class Friend < ActiveRecord::Base
  include SymmetryConcern

  belongs_to :ego, :class_name => 'User', :inverse_of => :friends
  belongs_to :user

  scope :for_index, order('updated_at DESC')

  validates_uniqueness_of :user, :scope => :ego
end
