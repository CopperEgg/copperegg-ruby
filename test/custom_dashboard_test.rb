require "test/unit"
require "copperegg"

class CustomDashboardTest < Test::Unit::TestCase

	def test_name_accessor_and_setter
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")

		assert_equal "My Dashboard", dashboard.name
	end

	def test_save_should_fail_if_name_is_not_set
		dashboard = CopperEgg::CustomDashboard.new

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Name can't be blank.", error.message
	end

	def test_save_should_fail_for_an_invalid_widget_type
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "foo", :style => "value", :match => "tag", :match_param => ["test"], 
																	:metric => {"my_metric_group" => [[0, "metric1"]]}}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Invalid widget type foo.", error.message
	end

	def test_save_should_fail_for_an_invalid_widget_style
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "foo", :match => "tag", :match_param => ["test"], 
																	:metric => {"my_metric_group" => [[0, "metric1"]]}}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Invalid widget style foo.", error.message
	end

	def test_save_should_ail_for_an_invalidvwidget_match
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "foo", :match_param => ["test"],
																	:metric => {"my_metric_group" => [[0, "metric1"]]}}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Invalid widget match foo.", error.message
	end

	def test_save_should_fail_for_a_missing_match_parameter
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "select", :metric => {"my_metric_group" => [[0, "metric1"]]}}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Missing match parameter.", error.message
	end

	def test_save_should_fail_if_metric_is_not_a_hash
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => ["my_metric_group", 0, "metric1"]}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Invalid widget metric.", error.message
	end

	def test_save_should_fail_if_metric_does_not_contain_an_array
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => "metric1"}}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Invalid widget metric.", error.message
	end

	def test_save_should_fail_if_metric_contains_an_empty_array
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => []}}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Invalid widget metric.", error.message
	end

	def test_save_should_fail_if_metric_contains_an_array_with_invalid_values
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => ["metric1"]}}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Invalid widget metric.", error.message
	end

	def test_save_should_fail_if_metric_contains_an_array_with_an_invalid_position
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => [["four", "metric1"]]}}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Invalid widget metric.", error.message
	end

	def test_save_should_fail_if_metric_contains_an_array_with_no_metric_name
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => [[0]]}}

		error = assert_raise(CopperEgg::ValidationError) { dashboard.save }
		assert_equal "Invalid widget metric.", error.message
	end

	# def test_save_should_save_a_valid_dashboard
	# 	CopperEgg::Api.apikey = "testapikey"

	# 	request_headers = {
	# 	  'Authorization' => "Basic #{Base64.encode64("testapikey:").gsub("\n",'')}",
	# 	  'Content-Type'  => 'application/json'
	# 	}

	# 	response_body = {:id => 1, :name => "My Dashboard", :data => {:widgets => [{:type => "metric", :style => "value", :match => "tag", :match_param => ["test"]}]},
	# 																																:order => ["0"]}
	  
	#   ActiveResource::HttpMock.respond_to do |mock|
	#     mock.post "/v2/revealmetrics/dashboards.json", request_headers, {}, 200
	#   end

	# 	dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
	# 	dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => [[1, "metric1"]]}}

	# 	assert dashboard.save
	# end

	def test_to_hash
		dashboard = CopperEgg::CustomDashboard.new(:name => "My Dashboard")
		dashboard.data.widgets["0"] = {:type => "metric", :style => "value", :match => "tag", :match_param => ["test"], :metric => {"my_metric_group" => [[1, "metric1"]]}}
		
		assert dashboard.valid?

		hash = dashboard.to_hash

		assert_equal "My Dashboard", hash["name"]
		assert_equal "metric", hash["data"]["widgets"]["0"]["type"]
		assert_equal "value", hash["data"]["widgets"]["0"]["style"]
		assert_equal "tag", hash["data"]["widgets"]["0"]["match"]
		assert_equal ["test"], hash["data"]["widgets"]["0"]["match_param"]
		assert_equal [[1, "metric1"]], hash["data"]["widgets"]["0"]["metric"]["my_metric_group"]
	end

end
