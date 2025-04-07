module EmailAddressVerification
  extend ActiveSupport::Concern
  MAX_TIME_FOR_VERIFICATION = 1.hours

  class_methods do
    def has_email_address_verification
      generates_token_for(:email_address_verification, expires_in: MAX_TIME_FOR_VERIFICATION)

      def self.find_by_email_address_verification_token(token)
        find_by_token_for(:email_address_verification, token)
      end
    end
  end

  def email_address_verification_token
    generate_token_for(:email_address_verification)
  end
end
