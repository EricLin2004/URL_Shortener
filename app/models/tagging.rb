class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :short_url

  attr_accessible :tag_id, :short_url_id

end