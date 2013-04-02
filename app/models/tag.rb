class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :short_urls, :through => :taggings

  attr_accessible :name

  #ALLOWED_TAGS = ["Cats", "Dogs", "Kittens", "Puppies"]

  def self.add(name)
    unless ALLOWED_TAGS.include?(name)
      raise 'Forbidden tag'
    end
    Tag.create(:name => name)
  end
end