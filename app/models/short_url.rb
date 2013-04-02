class ShortUrl < ActiveRecord::Base
  belongs_to :user
  belongs_to :long_url
  has_many :visits
  has_many :tags, :through => :taggings
  has_many :taggings
  
  attr_accessible :url, :user_id, :long_id

  def self.add(long_url, user)
    link = LongUrl.where(:url => long_url)
    if link == []
      long_url_id = LongUrl.create(:url => long_url).id
    else
      long_url_id = link.first.id
      if ShortUrl.where(:long_id => long_url_id, :user_id => user.id)
        raise 'You have already created a link for this URL.'
      end
    end
    short_url = "http://lande.com/#{SecureRandom.urlsafe_base64[0..4]}"
    ShortUrl.create(:url => short_url, :long_id => long_url_id, :user_id => user.id)
  end

  def self.find(long_url, user)
    long_id = LongUrl.where(:url => long_url).first.id
    ShortUrl.where(:long_id => long_id, :user_id => user.id)
  end

  def self.most_popular_url
    ShortUrl.joins(:visits)
              .group("short_urls.id")
              .order("COUNT(*) DESC").first
  end

end