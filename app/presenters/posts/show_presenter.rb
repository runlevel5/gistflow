class Posts::ShowPresenter
  attr_reader :controller, :post
  
  extend ActiveModel::Naming
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers
  
  delegate :user, :likes_count, :comments_count, :to => :post
  
  def initialize(post)
    @post = post
  end
  
  def cache_key
    "post:#{post.id}"
  end
  
  def preview
    @preview ||= (Markdown.markdown begin
      raw = Replaceable.new(post.preview, :preview => true)
      raw.replace_gists!.replace_tags!.replace_usernames!
      raw.body.html_safe
    end)
  end
  
  def body
    @body ||= (Markdown.markdown begin
      raw = Replaceable.new(post.body)
      raw.replace_gists!.replace_tags!.replace_usernames!
      raw.body
    end)
  end
  
  def title
    if post.title?
      c = link_to post.category, post_articles_path, :class => 'label'
      t = link_to post.title, post
      "#{t} #{c}".html_safe
    else
      simple_title
    end
  end
  
  def simple_title
    u = link_to user.username, user_path(:id => user.username), :class => 'username'
    t = link_to type.pluralize, type_path
    w = time_ago_in_words(post.created_at)
    "#{u} wrote in #{t} #{w} ago".html_safe
  end
  
  def detail_title
    if post.title?
      link_to post.title, post
    else
      simple_title
    end
  end
  
  def type
    post.type.split('::').last.downcase
  end
  
  def comments
    post.comments.to_a.select(&:persisted?)
  end
  
protected

  def type_path
    case post.class.to_s
    when 'Post::Article' then
      post_articles_path
    when 'Post::Question' then
      post_questions_path
    when 'Post::Gossip' then
      post_gossips_path
    end
  end
end