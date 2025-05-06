module Tokenable
  extend ActiveSupport::Concern

  class_methods do
    def acts_as_tokenable(column:, prefix: '', length: 10)
      return unless column

      define_method(:generate_token) do
        loop do
          token = "#{prefix}#{rand(10 ** length).to_s.rjust(length, '0')}"
          unless self.class.exists?(column => token)
            self.public_send("#{column}=", token)
            break
          end
        end
      end
    end
  end
end
