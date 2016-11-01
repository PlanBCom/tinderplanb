Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '1796712163924803', 'd004145e5f18f28a0487431d2bd16ccd' #, { :scope => 'user_location, user_birthday, user_about_me, email'}
end
