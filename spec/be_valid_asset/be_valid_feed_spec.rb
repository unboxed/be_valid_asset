require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

unless defined?(SpecFailed)
  SpecFailed = RSpec::Expectations::ExpectationNotMetError
end

RSpec.describe 'be_valid_feed' do

  describe "without caching" do
    it "should validate a valid string" do
      feed = get_file('valid_feed.xml')
      expect(feed).to be_valid_feed
    end

    it "should work when called as be_valid_rss" do
      feed = get_file('valid_feed.xml')
      expect(feed).to be_valid_rss
    end

    it "should work when called as be_valid_atom" do
      feed = get_file('valid_feed.xml')
      expect(feed).to be_valid_atom
    end

    it "should validate a valid response" do
      response = MockResponse.new(get_file('valid_feed.xml'))
      expect(response).to be_valid_feed
    end

    it "should validate if body is not a string but can be converted to valid string" do
      response = MockResponse.new(double("Feed", :to_s => get_file('valid_feed.xml')))
      expect(response).to be_valid_feed
    end

    it "should not validate an invalid string" do
      feed = get_file('invalid_feed.xml')
      expect {
        expect(feed).to be_valid_feed
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(/expected feed to be valid, but validation produced these errors/)
        expect(e.message).to match(/Invalid feed: line 12: Invalid email address/)
      }
    end

    it "should not validate an invalid response" do
      response = MockResponse.new(get_file('invalid_feed.xml'))
      expect {
        expect(response).to be_valid_feed
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(/expected feed to be valid, but validation produced these errors/)
        expect(e.message).to match(/Invalid feed: line 12: Invalid email address/)
      }
    end

    it "should display invalid content when requested" do
      BeValidAsset::Configuration.display_invalid_content = true
      feed = get_file('invalid_feed.xml')
      expect {
        expect(feed).to be_valid_feed
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(%r{<link>http://site.example.com/articles/article-1-title</link>})
      }
      BeValidAsset::Configuration.display_invalid_content = false
    end

    it "should fail unless response is HTTP OK" do
      feed = get_file('valid_feed.xml')

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.feed_validator_host)
      allow(h).to receive(:post).and_return(r)
      allow(Net::HTTP).to receive(:start).and_return(h)

      expect {
        expect(feed).to be_valid_feed
      }.to raise_error(RuntimeError, "HTTP error: 503")
    end

    it "should mark test as pending if ENV['NONET'] is true" do
      ENV['NONET'] = 'true'

      feed = get_file('valid_feed.xml')
      expect {
        expect(feed).to be_valid_feed
      }.to raise_error(BeValidAsset::DontRunValidAssetSpecs)

      ENV.delete('NONET')
    end
  end

  describe "with caching" do
    before(:each) do
      BeValidAsset::Configuration.enable_caching = true
      FileUtils.rm Dir.glob(BeValidAsset::Configuration.cache_path + '/*')
    end
    after(:each) do
      BeValidAsset::Configuration.enable_caching = false
    end

    it "should validate valid feed and cache the response" do
      feed = get_file('valid_feed.xml')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      expect(feed).to be_valid_feed
      expect(Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size).to eql(count + 1)
    end

    it "should validate valid feed using the cached response" do
      feed = get_file('valid_feed.xml')
      expect(feed).to be_valid_feed

      expect(Net::HTTP).not_to receive(:start)
      expect(feed).to be_valid_feed
    end

    it "should not validate invalid feed, but still cache the response" do
      feed = get_file('invalid_feed.xml')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      expect {
        expect(feed).to be_valid_feed
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(/expected feed to be valid, but validation produced these errors/)
        expect(e.message).to match(/Invalid feed: line 12: Invalid email address/)
      }
      expect(Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size).to eql(count + 1)
    end

    it "should not validate invalid feed, but use the cached response" do
      feed = get_file('invalid_feed.xml')
      expect(feed).not_to be_valid_feed

      expect(Net::HTTP).not_to receive(:start)
      expect {
        expect(feed).to be_valid_feed
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(/expected feed to be valid, but validation produced these errors/)
        expect(e.message).to match(/Invalid feed: line 12: Invalid email address/)
      }
    end

    it "should not cache the result unless it is an HTTP OK response" do
      feed = get_file('valid_feed.xml')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.feed_validator_host)
      allow(h).to receive(:post).and_return(r)
      allow(Net::HTTP).to receive(:start).and_return(h)

      expect {
        expect(feed).to be_valid_feed
      }.to raise_error(RuntimeError, "HTTP error: 503")
      expect(Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size).to eql(count)
    end

    it "should use the cached result (if available) when network tests disabled" do
      feed = get_file('valid_feed.xml')
      expect(feed).to be_valid_feed

      ENV['NONET'] = 'true'

      expect(Net::HTTP).not_to receive(:start)
      expect(feed).to be_valid_feed

      ENV.delete('NONET')
    end

    it "should mark test as pending if network tests are disabled, and no cached result is available" do
      ENV['NONET'] = 'true'

      feed = get_file('valid_feed.xml')
      expect {
        expect(feed).to be_valid_feed
      }.to raise_error(BeValidAsset::DontRunValidAssetSpecs)

      ENV.delete('NONET')
    end
  end
end
