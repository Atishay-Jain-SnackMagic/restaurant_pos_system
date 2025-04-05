class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attr, value)
    record.errors.add(attr, options[:message] || "is not a valid email") unless URI::MailTo::EMAIL_REGEXP.match?(value)
  end
end
