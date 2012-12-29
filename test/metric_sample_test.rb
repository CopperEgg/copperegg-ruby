require "active_support/test_case"
require "test/unit"
require "copperegg"

class MetricSampleTest < ActiveSupport::TestCase

	test "save should post a sample" do
		CopperEgg::Api.apikey = "testapikey"
		request_headers = {
		  'Authorization' => "Basic #{Base64.encode64("testapikey:").gsub("\n",'')}",
		  'Content-Type'  => 'application/json'
		}
	  
	  ActiveResource::HttpMock.respond_to do |mock|
	    mock.post "/v2/revealmetrics/samples//test.json", request_headers, {}, 200
	  end

		CopperEgg::MetricSample.save("test", "custom_object", Time.now.to_i, :key1 => "value1", :key2 => "value2")
	end

	test "samples should return the JSON response body upon success" do
		CopperEgg::Api.apikey = "testapikey"
		request_headers = {
		  'Authorization' => "Basic #{Base64.encode64("testapikey:").gsub("\n",'')}",
		  'Accept'  => 'application/json'
		}

		ActiveResource::HttpMock.respond_to do |mock|
			queries = {"queries" => {"metric_group" => [{"metrics" => ["metric1"]}]}}.to_param
			
	    mock.get "/v2/revealmetrics/samples.json?#{queries}", request_headers, {"_ts" => Time.now.to_i, "object_count" => 0, "values" => {"metric_group" => []}}.to_json, 200
	  end

	  CopperEgg::MetricSample.samples("metric_group", "metric1")
	end
	
end
