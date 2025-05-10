class AdminConstraint
  def self.matches?(request)
    user = User.find_by_token_for(:remember_me, request.cookie_jar.signed[:user_id_token])
    user&.is_admin?
  end
end
