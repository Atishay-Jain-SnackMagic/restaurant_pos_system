module Tokenable
  extend ActiveSupport::Concern

  included do
    class_attribute :token_config
  end

  class_methods do
    def acts_as_tokenable(column:, prefix: '', length: 10)
      self.token_config = { column: column, prefix: prefix, length: length }
    end
  end

  def generate_token
    return unless column = token_config[:column]

    prefix = token_config[:prefix]
    length = token_config[:length]

    loop do
      token = "#{prefix}#{rand(10 ** length).to_s.rjust(length, '0')}"
      unless self.class.exists?(column => token)
        public_send("#{column}=", token)
        break
      end
    end
  end
end
