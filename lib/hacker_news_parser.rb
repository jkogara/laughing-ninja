require 'net/http'
require 'yaml'
require 'json'
require File.join(File.dirname(__FILE__), 'email_sender')

API_ENDPOINT='http://api.ihackernews.com'

class HackerNewsParser

  include EmailSender

  attr_accessor :front_page_url, :front_page, :response_code
  attr_writer :items


  def initialize(options = {})
    url = options.has_key?(:page) ? options[:page] : 'page'
    @front_page_url = URI.parse([API_ENDPOINT, url].join('/'))
    @front_page = Proc.new { get_front_page }
  end

  def items_above_mean_score
    mean_score = mean
    items.select { |item| item['points'] > mean_score }.sort{|a,b| b['points'] <=> a['points']}
  end

  def items(refresh = false)
    @items = refresh || @items.nil? ? front_page.call["items"] : @items
  end

  def refresh
    items(true)
  end

  #collect the points from each item on the front page
  def scores
    items.collect { |item| item['points'] }
  end

  #Request the front page, is the site is down or something goes wrong return something sensible
  def get_front_page(refresh = false)
    http = Net::HTTP.new(front_page_url.host, front_page_url.port)
    response = http.request(Net::HTTP::Get.new(front_page_url.request_uri))
    @response_code = response.code.to_i
    if response.code == '200'
      JSON.parse(response.body)
    else
      {'code' => response.code,
       'message' => ['Unexpected Response from', front_page_url].join(' '),
       'items' => []}
    end
  rescue
    @response_code = 500
    return {'code' => 500,
            'message' => ['Unexpected Response from', front_page_url].join(' '),
            'items' => []}
  end

  #calculate the mean of the point, be sure to return a float
  def mean(arr = nil)
    arr ||= scores
    return (arr.reduce(0) { |sum, item| sum + item }.to_f / arr.count) unless arr.empty?
    nil
  end

  #calculate the median score
  def median(arr = nil)
    arr ||= scores
    return nil if arr.empty?
    arr.sort!
    center = (count = arr.count) / 2
    count % 2 == 1 ? arr[center] : mean(arr[center-1..center])
  end

  #calculate the mode of the points, if it is multi-modal return all mode values
  def modal(arr = nil)
    arr ||= scores
    return nil if arr.nil? || arr.empty? || arr.uniq.count == arr.count
    score_table = arr.each_with_object(Hash.new(0)) { |val, hash| hash[val] +=1 }

    score_table.keys.each_with_object(modes = Array.new) do |key|
      count = score_table[key]
      modes << key if count == modes[0]
      modes = [count, key] if (modes.empty? && count > 1) || (!modes.empty? && count > modes[0])
    end
    modes.empty? ? nil : modes[1...modes.size]
  end

end

