require 'active_support/json'

module CopperEgg
  class Utils

    attr_accessor :apikey

    def initialize(apikey, product, apihost=nil)
      @apikey = apikey
      @product = product
      if apihost
        @apihost = apihost
      else
        @apihost = DEFAULTS[:apihost]
      end
    end

    def make_api_get_request(api_cmd, apikey, params)
      response = make_api_request("get", api_cmd, apikey, params)
      return response
    end

    def make_api_post_request(api_cmd, apikey, body)
      response = make_api_request("post", api_cmd, apikey, body)
      return response
    end

    private

    def make_uri(api_cmd)
      return URI.parse("#{@apihost}/#{API_VERSION}/#{@product}#{api_cmd}")
    end

    def make_api_request(type, api_cmd, apikey, params)
      request = nil
      uri = make_uri(api_cmd)
      http = Net::HTTP.new(uri.host, uri.port)

      if type == "get"
        uri.query = URI.encode_www_form(params) if !params.nil?
        request = Net::HTTP::Get.new(uri.request_uri)
      else
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = params.to_json
      end
      
      request.basic_auth(apikey, "U")
      request["Content-Type"] = "application/json"
      response = http.request(request)
      if response.code != "200"
        return nil
      end
      return response
    end

  end
end
