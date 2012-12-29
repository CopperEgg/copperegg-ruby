require "active_support/test_case"
require "test/unit"
require "copperegg"

class CustomDashboardTest < ActiveSupport::TestCase

	test "name accessor and setter" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")

		assert_equal "My Dashboard", dashboard.name
		assert_equal "My Dashboard", dashboard.attributes["name"]

		dashboard.name = "Redis Dashboard"

		assert_equal "Redis Dashboard", dashboard.name
		assert_equal "Redis Dashboard", dashboard.attributes["name"]
	end

	test "save should fail if name is not set" do
		dashboard = CopperEgg::CustomDashboard.new

		assert !dashboard.save
		assert_equal ["can't be blank"], dashboard.errors[:name]
	end

	test "save should fail for an invalid widget type" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "foo", :style => "value", :match => "tag", :match_param => ["test"], 
																	:metric => {"my_metric_group" => [[0, "metric1"]]}}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Invalid widget type foo."], dashboard.errors[:data]
	end

	test "save should fail for an invalid widget style" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "foo", :match => "tag", :match_param => ["test"], 
																	:metric => {"my_metric_group" => [[0, "metric1"]]}}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Invalid widget style foo."], dashboard.errors[:data]
	end

	test "save should fail for an invalid widget match" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "foo", :match_param => ["test"],
																	:metric => {"my_metric_group" => [[0, "metric1"]]}}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Invalid widget match foo."], dashboard.errors[:data]
	end

	test "save should fail for a missing match parameter" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "select", :metric => {"my_metric_group" => [[0, "metric1"]]}}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Missing match parameter."], dashboard.errors[:data]
	end

	test "save should fail if metric is not a hash" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => ["my_metric_group", 0, "metric1"]}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Invalid widget metric."], dashboard.errors[:data]
	end

	test "save should fail if metric does not contain an array" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => "metric1"}}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Invalid widget metric."], dashboard.errors[:data]
	end

	test "save should fail if metric contains an empty array" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => []}}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Invalid widget metric."], dashboard.errors[:data]
	end

	test "save should fail if metric contains an array with invalid values" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => ["metric1"]}}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Invalid widget metric."], dashboard.errors[:data]
	end

	test "save should fail if metric contains an array with an invalid position" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => [["four", "metric1"]]}}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Invalid widget metric."], dashboard.errors[:data]
	end

	test "save should fail if metric contains an array with no metric name" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => [[0]]}}

		assert !dashboard.save
		assert_equal 1, dashboard.errors.size
		assert_equal ["Invalid widget metric."], dashboard.errors[:data]
	end

	test "save should save a valid dashboard" do
		CopperEgg::Api.apikey = "testapikey"

		request_headers = {
		  'Authorization' => "Basic #{Base64.encode64("testapikey:").gsub("\n",'')}",
		  'Content-Type'  => 'application/json'
		}

		response_body = {:id => 1, :name => "My Dashboard", :data => {:widgets => [{:type => "metric", :style => "value", :match => "tag", :match_param => ["test"]}]},
																																	:order => ["0"]}
	  
	  ActiveResource::HttpMock.respond_to do |mock|
	    mock.post "/v2/revealmetrics/dashboards.json", request_headers, {}, 200
	  end

		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => [[1, "metric1"]]}}

		assert dashboard.save
	end

	test "to_json" do
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => [[1, "metric1"]]}}
		
		assert dashboard.valid?

		json = JSON.parse(dashboard.to_json)

		assert_equal "My Dashboard", json["name"]
		assert_equal "metric", json["data"]["widgets"]["0"]["type"]
		assert_equal "value", json["data"]["widgets"]["0"]["style"]
		assert_equal "tag", json["data"]["widgets"]["0"]["match"]
		assert_equal ["test"], json["data"]["widgets"]["0"]["match_param"]
		assert_equal [[1, "metric1"]], json["data"]["widgets"]["0"]["metric"]["my_metric_group"]
	end

end
