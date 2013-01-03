require "test/unit"
require "copperegg"

class MetricGroupTest < Test::Unit::TestCase

	def test_name_accessor_and_setter
		metric_group = CopperEgg::MetricGroup.new(:name => "my_metric_group")

		assert_equal "my_metric_group", metric_group.name
	end

	def test_save_should_fail_if_name_is_blank
		metric_group = CopperEgg::MetricGroup.new

		error = assert_raise(CopperEgg::ValidationError) { metric_group.save }
		assert_equal "Name can't be blank.", error.message
	end

	def test_save_should_fail_if_no_metrics_are_declared
		metric_group = CopperEgg::MetricGroup.new(:name => "my_metric_group")

		error = assert_raise(CopperEgg::ValidationError) { metric_group.save }
		assert_equal "You must define at least one metric.", error.message
	end

	def test_save_should_fail_if_metrics_include_non_metric
		metric_group = CopperEgg::MetricGroup.new(:name => "my_metric_group", :metrics => ["metric"])

		error = assert_raise(CopperEgg::ValidationError) { metric_group.save }
		assert_equal "Metric expected.", error.message
	end

	def test_save_should_fail_for_invalid_metrics
		metric_group = CopperEgg::MetricGroup.new(:name => "my_metric_group", :metrics => [{:name => "test", :type => "invalid"}])

		error = assert_raise(CopperEgg::ValidationError) { metric_group.save }
		assert_equal "Invalid metric type invalid.", error.message
	end

	# def test_save_should_retrieve_versioned_name_of_metric_group
	# 	CopperEgg::Api.apikey = "testapikey"

	# 	request_headers = {
	# 	  'Authorization' => "Basic #{Base64.encode64("testapikey:").gsub("\n",'')}",
	# 	  'Content-Type'  => 'application/json'
	# 	}
	# 	response_body = {:id => "test_v2", :name => "test_v2", :label => "Test", :frequency => 5, :metrics => [{:name => "test", :type => "ce_counter", :position => 0}]}
	  
	#   ActiveResource::HttpMock.respond_to do |mock|
	#     mock.post "/v2/revealmetrics/metric_groups.json", request_headers, response_body.to_json, 200
	#   end

	# 	metric_group = CopperEgg::MetricGroup.new(:name => "test", :frequency => 5, :metrics => [{:name => "test", :type => "ce_counter"}])

	# 	metric_group.save

	# 	assert_equal "test_v2", metric_group.id
	# 	assert_equal "test_v2", metric_group.name
	# end

	def test_to_hash
		metric_group = CopperEgg::MetricGroup.new(:name => "test", :label => "Test Metric", :frequency => 5)
		metric_group.metrics << {:type => "ce_counter", :name => "metric1", :label => "Metric 1", :unit => "ticks"}
		metric_group.metrics << {:type => "ce_counter_f", :name => "metric2", :label => "Metric 2"}

		assert metric_group.valid?
		hash = metric_group.to_hash

		assert_nil hash["id"]
		assert_equal "test", hash["name"]
		assert_equal "Test Metric", hash["label"]
		assert_equal 5, hash["frequency"]
		assert_equal "ce_counter", hash["metrics"].first["type"]
		assert_equal "metric1", hash["metrics"].first["name"]
		assert_equal "Metric 1", hash["metrics"].first["label"]
		assert_equal "ticks", hash["metrics"].first["unit"]
		assert_equal "ce_counter_f", hash["metrics"].last["type"]
		assert_equal "metric2", hash["metrics"].last["name"]
		assert_equal "Metric 2", hash["metrics"].last["label"]
	end

end
