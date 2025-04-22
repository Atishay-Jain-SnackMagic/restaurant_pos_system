class CurrentDateValidator < ActiveModel::EachValidator
  def validate_each(reccord, attr, value)
    record.errors.add(attr, options[:message] || 'should have current date') unless value.today?
  end
end
