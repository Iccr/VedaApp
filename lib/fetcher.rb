require 'rest-client'

class Fetcher

  def initialize url, headers = nil
    @url = url
    if headers.is_a? Hash
      @headers = headers || {}
    end
  end

  def fetch
    @json = RestClient.get(@url, headers = @headers)
    @json
  end
end
