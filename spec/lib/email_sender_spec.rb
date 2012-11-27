require 'email_sender'
require 'rspec'
require 'email_spec'
require 'hacker_news_parser'
require 'factory_girl'



describe 'Email Sender' do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  before(:each) do
    @fake_class = FactoryGirl.build(:hacker_news_parser)
  end

  describe 'email sender methods' do
    it "should have send_hacker_summary" do
      @fake_class.should respond_to(:send_hacker_summary)
    end

    it "should send an email to someone" do
      @fake_class.send_hacker_summary.should deliver_to('jogara@localhost')
    end
  end

end

