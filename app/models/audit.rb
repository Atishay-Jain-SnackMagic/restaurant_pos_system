class Audit < ApplicationRecord
  belongs_to :auditable, polymorphic: true
end
