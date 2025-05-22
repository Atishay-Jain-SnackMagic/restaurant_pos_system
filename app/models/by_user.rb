class ByUser <  ApplicationRecord
  validate :ensure_email_present
  validates :email, presence: true

  private def ensure_email_present
    self.email = 'abc'
  end
end
