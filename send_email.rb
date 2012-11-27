#!/bin/env ruby
require 'optparse'
require 'highline'
require File.join(File.dirname(__FILE__),'lib/hacker_news_parser.rb')

EMAIL_VALIDATION = /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i

class SendEmail

  def self.main(args)
    opts = parse_options(args)
    h = HighLine.new

    opts[:to] = h.ask("Enter a valid email address to send the summary to") until opts[:to] =~ EMAIL_VALIDATION
    opts[:from] = h.ask("Enter a valid email address for the sender") until opts[:from] =~ EMAIL_VALIDATION

    h = HackerNewsParser.new
    h.send_hacker_summary(opts)

  end

  def self.parse_options(args, options = {})
    opt_parse = OptionParser.new

    opt_parse.on('-t', '--to EMAIL_ADDRESS') do |o|
      options[:to] = o
    end

    opt_parse.on('-f', '--from EMAIL_ADDRESS') do |o|
      options[:from] = o
    end

    opt_parse.parse args

    options

  end

end

SendEmail.main(ARGV)
