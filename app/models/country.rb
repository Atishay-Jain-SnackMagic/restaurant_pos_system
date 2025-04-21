class Country < ActiveJSON::Base
  set_root_path 'db/data'
  set_filename 'countries'
end
