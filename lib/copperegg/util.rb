require 'multi_json'

module CopperEgg
  class Util

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

      http.use_ssl = uri.scheme == 'https'
      if !DEFAULTS[:ssl_verify_peer]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      if type == "get"
        request = Net::HTTP::Get.new(uri.request_uri)
        request.body = MultiJson.dump(params)
      else
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = MultiJson.dump(params)
      end

      request.basic_auth(apikey, "U")
      request["Content-Type"] = "application/json"

      connect_try_count = 0
      response = nil
      begin
        response = http.request(request)
      rescue Exception => e
        connect_try_count += 1
        if connect_try_count > 1
          log "#{e.inspect}"
          raise e
        end
        sleep 0.5
        retry
      end

      if response == nil || response.code != "200"
        return nil
      end
      if type == "get"
        return response.body
      else
        return response
      end
    end

  end
end
