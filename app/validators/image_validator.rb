class ImageValidator < ActiveModel::EachValidator
  VALID_IMAGE_FORMATS = %w[ image/jpeg image/png image/gif image/jpg ].freeze

  def validate_each(record, attr, value)
    record.errors.add(attr, (options[:message] || t('validators.image.failure'))) unless value&.content_type.in?(VALID_IMAGE_FORMATS)
  end
end
