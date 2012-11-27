require 'factory_girl'
require 'uri'

FactoryGirl.define do
  factory :hacker_news_parser do
    items []
    front_page_url URI.parse('http://api.ihackernews.com/page')
    front_page  Proc.new{{}}
    response_code 200
  end
end
