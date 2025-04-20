class Country < ActiveJSON::Base
  set_root_path 'app/data'
  set_filename 'countries'
end
