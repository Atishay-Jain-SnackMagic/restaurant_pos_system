module Tokenable
  extend ActiveSupport::Concern

  included do
    class_attribute :column, :prefix, :length
  end

  class_methods do
    def acts_as_tokenable(column:, prefix: '', length: 10)
      self.column = column
      self.prefix = prefix
      self.length = length
    end
  end

  def generate_token
    return unless column

    loop do
      token = "#{prefix}#{rand(10 ** length).to_s.rjust(length, '0')}"
      unless self.class.exists?(column => token)
        public_send("#{column}=", token)
        break
      end
    end
  end
end
