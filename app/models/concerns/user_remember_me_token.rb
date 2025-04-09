module UserRememberMeToken
  extend ActiveSupport::Concern
  MAX_DURATION_FOR_REMEMBER_ME_TOKEN = 1.months

  class_methods do
    def has_user_remember_me_token
      generates_token_for(:remember_me, expires_in: MAX_DURATION_FOR_REMEMBER_ME_TOKEN)

      def self.find_by_remember_me_token(token)
        User.find_by_token_for(:remember_me, token)
      end
    end
  end

  def remember_me_token
    generate_token_for(:remember_me)
  end
end
