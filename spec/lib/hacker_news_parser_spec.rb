require 'rspec'
require 'factory_girl'
require 'hacker_news_parser'

FactoryGirl.find_definitions


describe HackerNewsParser do

  describe 'front_page_url' do

    before(:each) do
      @instance = FactoryGirl.build(:hacker_news_parser)
    end

    it "should have a front_page_url" do
      @instance.should respond_to(:front_page_url)
      @instance.front_page_url.should be_a(URI)
    end
  end

  describe "front_page" do

    before(:each) do
      @instance = FactoryGirl.build(:hacker_news_parser, :front_page => Proc.new { {'code' => 200, 'items' => []} })
    end

    it "should have a front_page" do
      @instance.stub(:get_front_page).and_return({'code' => 200, 'items' => []})
      @instance.should respond_to(:front_page)
      @instance.front_page.should be_a(Proc)
    end

    it "should return a hash when front_page is called" do
      @instance.stub(:get_front_page).and_return({'code' => 200, 'items' => []})
      @instance.should respond_to(:front_page)
      @instance.front_page.call.should be_a(Hash)
    end

    it "should have a code and items in the front_page" do
      @instance.stub(:get_front_page).and_return({'code' => 200, 'items' => []})
      @instance.front_page.call.keys.should include('code')
      @instance.front_page.call.keys.should include('items')
    end

  end

  describe "items" do
    before(:each) do
      @instance = FactoryGirl.build(:hacker_news_parser, :front_page => {})
    end

    it 'should respond to items' do
      @instance.should respond_to(:items)
    end

    it "items should return an array" do
      @instance.stub(:get_front_page).and_return({'items' => []})
      @instance.items.should be_a(Array)
    end
  end

  describe "scores" do
    before(:each) do
      @instance = FactoryGirl.build(:hacker_news_parser, :front_page => {})
    end

    it "should respond to scores" do
      @instance.should respond_to(:scores)
    end

    it "should return an array" do
      @instance.should_receive(:items).and_return([])
      @instance.scores.should be_a(Array)
    end
  end

  describe 'get_front_page' do
    before(:each) do
      @instance = FactoryGirl.build(:hacker_news_parser,
                                    :front_page_url => URI.parse('http://localhost/page'))
    end

    it 'should respond to get_front_page' do
      @instance.should respond_to(:get_front_page)
    end

    it 'should return a hash from get_front_page and have a code' do
      @instance.get_front_page.should be_a(Hash)
      @instance.get_front_page.keys.should include('code')
    end

  end


  describe "mean" do
    before(:each) do
      @mean_factory ||= FactoryGirl.build(:hacker_news_parser)
    end

    it "should respond to mean" do
      @mean_factory.should respond_to(:mean)
    end

    it "should return an nil if there are no items" do
      @mean_factory.should_receive(:scores).any_number_of_times.and_return([])
      @mean_factory.mean.should be_nil
    end

    it "should return a float for mean" do
      @mean_factory.should_receive(:scores).any_number_of_times.and_return([2, 3])
      @mean_factory.mean.should be_a(Float)
    end

    it "should return the correct value for mean" do
      @mean_factory.should_receive(:scores).any_number_of_times.and_return([2, 2])
      @mean_factory.mean.should eq(2)
    end

  end

  describe "median" do
    before(:each) do
      @median_factory ||= FactoryGirl.build(:hacker_news_parser)
    end

    it "should respond to median" do
      @median_factory.should respond_to(:mean)
    end

    it "should return an nil if there are no items" do
      @median_factory.should_receive(:scores).and_return([])
      @median_factory.median.should be_nil
    end

    it "should return the correct value for median" do
      @median_factory.should_receive(:scores).and_return([1, 2, 3])
      @median_factory.median.should eq(2)
    end

    it "should call mean if there are an even number of elements" do
      @median_factory.should_receive(:scores).and_return([1, 2, 3, 4])
      @median_factory.should_receive(:mean).and_return(2.5)
      median = @median_factory.median
      median.should eq(2.5)
    end

  end

  describe "modal" do
    before(:each) do
      @modal_factory = FactoryGirl.build(:hacker_news_parser)
    end

    it "should respond to modal" do
      @modal_factory.should respond_to(:modal)
    end

    it "should return an array if there is a modal" do
      @modal_factory.should_receive(:scores).and_return([1, 1, 2])
      @modal_factory.modal.should be_a(Array)
    end

    it "should return nil if there no modal" do
      @modal_factory.should_receive(:scores).and_return([1, 2])
      @modal_factory.modal.should be_nil
    end

    it "should return the correct value if there is a single mode" do
      @modal_factory.should_receive(:scores).and_return([1, 1, 2])
      @modal_factory.modal.should eq([1])
    end

    it "should return the correct value if there is multi-modal" do
      @modal_factory.should_receive(:scores).and_return([1, 1, 2, 2])
      @modal_factory.modal.should eq([1, 2])
    end

  end

  describe 'items with a score above the mean' do
    before(:each) do
      @above_the_mean = FactoryGirl.build(:hacker_news_parser)
    end


    it 'should respond to items_above_the_mean_score' do
      @above_the_mean.should respond_to(:items_above_mean_score)
    end

    it 'should return an array when called' do
      @above_the_mean.should_receive(:items).and_return([])
      @above_the_mean.should_receive(:mean).and_return(nil)
      @above_the_mean.items_above_mean_score.should be_a(Array)
    end

    it 'should return all items above the mean' do
      @above_the_mean.should_receive(:items).any_number_of_times.and_return(
          [{'points' => 1, 'url' => "http://example1", 'title' => 'below mean'},
           {'points' => 100, 'url' => "http://example2", 'title' => 'above mean'},
           {'points' => 100, 'url' => "http://example3", 'title' => 'above mean'},
           {'points' => 100, 'url' => "http://example4", 'title' => 'above mean'},])
      @above_the_mean.should_receive(:mean).any_number_of_times.and_return(75.25)
      @above_the_mean.items_above_mean_score.should be_a(Array)
      @above_the_mean.items_above_mean_score.count.should eq(3)
      @above_the_mean.items_above_mean_score.collect { |item| item['url'] }.should == %w{http://example2
                                                                                        http://example3
                                                                                        http://example4}
    end

  end

  describe 'items_above_mean_score' do
    before(:each) do
      @above_the_mean = FactoryGirl.build(:hacker_news_parser)
    end


    it 'should respond to items_above_the_mean_score' do
      @above_the_mean.should respond_to(:items_above_mean_score)
    end

    it 'should return an array when called' do
      @above_the_mean.should_receive(:items).and_return([])
      @above_the_mean.should_receive(:mean).and_return(nil)
      @above_the_mean.items_above_mean_score.should be_a(Array)
    end

    it 'should return all items above the mean' do
      @above_the_mean.should_receive(:items).any_number_of_times.and_return(
          [{'points' => 1, 'url' => "http://example1", 'title' => 'below mean'},
           {'points' => 100, 'url' => "http://example2", 'title' => 'above mean'},
           {'points' => 100, 'url' => "http://example3", 'title' => 'above mean'},
           {'points' => 100, 'url' => "http://example4", 'title' => 'above mean'},])
      @above_the_mean.should_receive(:mean).any_number_of_times.and_return(75.25)
      @above_the_mean.items_above_mean_score.should be_a(Array)
      @above_the_mean.items_above_mean_score.count.should eq(3)
      @above_the_mean.items_above_mean_score.collect { |item| item['url'] }.should == %w{http://example2
                                                                                        http://example3
                                                                                        http://example4}
    end

    it 'should return the items in descending order or points' do
      @above_the_mean.should_receive(:items).any_number_of_times.and_return(
          [{'points' => 1, 'url' => "http://example1", 'title' => 'below mean'},
           {'points' => 75, 'url' => "http://example4", 'title' => 'above mean'},
           {'points' => 100, 'url' => "http://example3", 'title' => 'above mean'},])
      items_above_score = @above_the_mean.items_above_mean_score
      items_above_score.last['points'].should < items_above_score.first['points']
    end

  end


end
