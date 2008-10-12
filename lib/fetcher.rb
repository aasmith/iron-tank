class Fetcher
  class_inheritable_accessor :institution, :fid

  cattr_accessor :fetchers

  class << self
    def resolve(opts)
      opts.symbolize_keys!

      @@fetchers.detect do |fetcher|
        opts.all? do |property, value|
          fetcher.send(property) == value rescue nil
        end
      end
    end
  end

  private

  def self.inherited(subclass)
    @@fetchers ||= []
    @@fetchers << subclass
  end
end

Dir.glob(File.join(File.dirname(__FILE__), 'fetchers/*.rb')).each {
  |f| require f
}
