class User < ApplicationRecord
  belongs_to :default_location, class_name: "Location"
end
