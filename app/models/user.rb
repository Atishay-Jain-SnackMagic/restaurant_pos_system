class User < ApplicationRecord
  belongs_to :default_location, class: "Location"
end
