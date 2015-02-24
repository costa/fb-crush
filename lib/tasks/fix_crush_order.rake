task :fix_crush_order => :environment do
  User.find_each do |user|
    user.friends.order('updated_at DESC').where(intention: 'love').each do |friend|
      begin
        def friend.notify?; false; end
        friend.save!
      rescue => e
        Rails.logger.error "#{friend.id}:\n#{e.backtrace}\n- #{e.message} (#{e.class})"
      end
    end
  end
  User.find_each do |user|
    user.fetch_friends_async true
  end
end
