def run
  user = get_user
  loop do
    input = get_input
    case input
    when 1
      add_url(user)
    when 2
      launch(user)
    when 3
      add_comment(user)
    when 4
      print_stats
    when 5
      print_user_links
    when 6
      add_tags
    when 7
      show_tags
    when 8
      most_popular_url
    when 9
      break
    end
  end
end

def get_user
  puts "What's your screen name?"
  screen_name = gets.chomp
  user = User.find_by_screen_name(screen_name)
  if user == nil
    puts "No user with that screen name found, " +
    "creating new account. What's your e-mail?"
    e_mail = gets.chomp
    user = User.create(:screen_name => screen_name, :e_mail => e_mail)
  end
  user
end

def get_input
  puts "What would you like to do?"
  puts "1. Add URL"
  puts "2. Open URL"
  puts "3. Add comment"
  puts "4. Print URL stats"
  puts "5. Print user's links"
  puts "6. Add tag to URL"
  puts "7. Show tags on URL"
  puts "8. Show most popular URL"
  puts "9. Quit"
  valid_input = false
  until valid_input
    input = gets.chomp.scan(/\d/)
    valid_input = true if input.length == 1
  end
  input.first.to_i
end

def most_popular_url
  puts ShortUrl.most_popular_url.url
end

def add_tags
  puts "Input link to tag:"
  input_url = gets.chomp
  puts "Enter tag for your link:"
  input_tag = gets.chomp
  find_tag = Tag.find_by_name(input_tag)
  if find_tag.nil?
    tag_id = Tag.create(:name => input_tag).id
  else
    tag_id = find_tag.id
  end
  find_short_url = ShortUrl.find_by_url(input_url)
  Tagging.create(:tag_id => tag_id, :short_url_id => find_short_url.id)
end

def show_tags
  puts "Which short URL are you interested in?"
  input_url = gets.chomp
  short_url = ShortUrl.find_by_url(input_url)
  tagging_objs = Tagging.select('tag_id')
                        .joins(:short_url)#{}"JOIN short_urls ON taggings.short_url_id = #{short_url.id}")
                        .where('short_urls.url = ?',  input_url)
  tagging_objs.each do |tagging|
    puts Tag.find(tagging.tag_id).name
  end
end

def add_url(user)
  puts "Enter the URL you would like shortened:"
  long_url = gets.chomp
  short_url = ShortUrl.add(long_url, user)
  puts short_url.url
end

def launch(user)
  puts "Enter shortened URL:"
  input_url = gets.chomp
  short_url = ShortUrl.find_by_url(input_url)
  if short_url
    print_comments(short_url)
    long_url = LongUrl.find_by_id(short_url.long_id)
    Launchy.open(long_url.url)
    Visit.create(:user_id => user.id, :short_url_id => short_url.id)
  else
    raise 'That short url is not in the database.'
  end
end

def print_comments(short_url)
  Comment.where(:short_url_id => short_url.id).each do |comment|
    puts comment.body
  end
end

def add_comment(user)
  puts "Which link would you like to comment on?"
  input_url = gets.chomp
  short_url = ShortUrl.find_by_url(input_url)
  if short_url == nil
    raise "No such link!"
  else
    puts "Enter comment:"
    body = gets.chomp
    Comment.create(:user_id => user.id, :short_url_id => short_url.id,
                   :body => body)
    puts "Comment recorded."
  end
end

def print_stats
  puts "Enter URL to print stats for:"
  input_url = gets.chomp
  short_url = ShortUrl.find_by_url(input_url)
  visitors = Visit.where(:short_url_id => short_url.id)
  current_time = Time.now - 600
  past_ten_min = Visit.where("created_at >= ?", Time.now - 10.minutes)

  puts "Number of Visitors : #{visitors.count}"
  puts "Number of Unique Visitors : #{visitors.count(:user_id, :distinct => true)}"
  puts "Visitors in past ten minutes:"
  puts past_ten_min
end

def print_user_links
  puts "Enter user to print links for:"
  input_user = gets.chomp
  user = User.find_by_screen_name(input_user)
  if user.nil?
    raise "No such user!"
  else
    ShortUrl.where(:user_id => user.id).each do |short_url|
      puts "Short form: #{short_url.url}"
      puts "Long form: #{LongUrl.find_by_id(short_url.long_id).url}"
    end
  end
end

run