module Auditable
  extend ActiveSupport::Concern

  included do
    class_attribute :auditable_attributes
    has_many :audits, as: :auditable, dependent: :destroy
    after_save :audit_changes
  end

  class_methods do
    def acts_as_auditable(*attributes)
      self.auditable_attributes = attributes.map(&:to_s).uniq
    end
  end

  private def audit_changes
    return unless auditable_attributes

    auditable_attributes.each do |attr|
      next unless previous_changes.keys.include?(attr)

      change = previous_changes[attr]
      audits.create(attribute_name: attr, old_value: change[0], new_value: change[1])
    end
  end
end
