require "active_support/test_case"
require "test/unit"
require "copperegg"

class MetricGroupTest < ActiveSupport::TestCase

	test "name accessor and setter" do
		metric_group = CopperEgg::MetricGroup.new(:name => "my_metric_group")

		assert_equal "my_metric_group", metric_group.name
		assert_equal "my_metric_group", metric_group.attributes["name"]

		metric_group.name = "my_metric_group_v2"

		assert_equal "my_metric_group_v2", metric_group.name
		assert_equal "my_metric_group_v2", metric_group.attributes["name"]
	end

	test "save should fail if name is blank" do
		metric_group = CopperEgg::MetricGroup.new

		assert !metric_group.save
		assert_equal ["can't be blank"], metric_group.errors[:name]
	end

	test "save should fail if no metrics are declared" do
		metric_group = CopperEgg::MetricGroup.new(:name => "my_metric_group")

		assert !metric_group.save
		assert_equal 1, metric_group.errors.size
		assert_equal ["You must define at least one metric."], metric_group.errors[:metrics]
	end

	test "save should fail if metrics include non-metric" do
		metric_group = CopperEgg::MetricGroup.new(:name => "my_metric_group", :metrics => ["metric"])

		assert !metric_group.save
		assert_equal 1, metric_group.errors.size
		assert_equal ["Metric expected."], metric_group.errors[:metrics]
	end

	test "save should fail for invalid metrics" do
		metric_group = CopperEgg::MetricGroup.new(:name => "my_metric_group", :metrics => [{:name => "test", :type => "invalid"}])

		assert !metric_group.save
		assert_equal 1, metric_group.errors.size
		assert_equal ["Invalid metric type invalid."], metric_group.errors[:metrics]
	end

	test "save should retrieve versioned name of metric group" do
		CopperEgg::Api.apikey = "testapikey"

		request_headers = {
		  'Authorization' => "Basic #{Base64.encode64("testapikey:").gsub("\n",'')}",
		  'Content-Type'  => 'application/json'
		}
		response_body = {:id => "test_v2", :name => "test_v2", :label => "Test", :frequency => 5, :metrics => [{:name => "test", :type => "ce_counter", :position => 0}]}
	  
	  ActiveResource::HttpMock.respond_to do |mock|
	    mock.post "/v2/revealmetrics/metric_groups.json", request_headers, response_body.to_json, 200
	  end

		metric_group = CopperEgg::MetricGroup.new(:name => "test", :frequency => 5, :metrics => [{:name => "test", :type => "ce_counter"}])

		metric_group.save

		assert_equal "test_v2", metric_group.id
		assert_equal "test_v2", metric_group.name
	end

	test "to_json" do
		metric_group = CopperEgg::MetricGroup.new(:name => "test", :label => "Test Metric", :frequency => 5)
		metric_group.metrics << {:type => "ce_counter", :name => "metric1", :label => "Metric 1", :unit => "ticks"}
		metric_group.metrics << {:type => "ce_counter_f", :name => "metric2", :label => "Metric 2"}

		assert metric_group.valid?
		json = JSON.parse(metric_group.to_json)

		assert_nil json["id"]
		assert_equal "test", json["name"]
		assert_equal "Test Metric", json["label"]
		assert_equal 5, json["frequency"]
		assert_equal "ce_counter", json["metrics"].first["type"]
		assert_equal "metric1", json["metrics"].first["name"]
		assert_equal "Metric 1", json["metrics"].first["label"]
		assert_equal "ticks", json["metrics"].first["unit"]
		assert_equal "ce_counter_f", json["metrics"].last["type"]
		assert_equal "metric2", json["metrics"].last["name"]
		assert_equal "Metric 2", json["metrics"].last["label"]
	end

end
