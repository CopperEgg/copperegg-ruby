module CopperEgg
  class Metrics

    attr_accessor :apikey

    def initialize(apikey, apihost=nil)
      @apikey = apikey
      @util = CopperEgg::Util.new(@apikey, "revealmetrics", apihost)
    end

    def store_sample(group_name, identifier, timestamp, metric_data)
      return if identifier.nil?
      return if group_name.nil?
      return if timestamp.nil? || timestamp == 0
      return if metric_data.nil?

      payload = {}
      payload["timestamp"] = timestamp
      payload["identifier"] = identifier
      payload["values"] = metric_data

      @util.make_api_post_request("/samples/#{group_name}.json", @apikey, payload)
    end

    def samples(group_name, metricname, starttime=nil, duration=nil, sample_size=nil)
      return if group_name.nil?
      return if metricname.nil?

      metric_name = []
      metrics = {}
      metric_gid = []
      query = {}
      params = {}

      metric_name = [metricname]
      metrics["metrics"] = metric_name
      metric_gid = [metrics]
      query[group_name] = metric_gid
      params["queries"] = query
      params["starttime"] = starttime if !starttime.nil?
      params["duration"] = duration if !duration.nil?
      params["sample_size"] = sample_size if !sample_size.nil?

      @util.make_api_get_request("/samples.json", @apikey, params)
    end

    def metric_groups
      # return an array of metric groups
      @util.make_api_get_request("/metric_groups.json", @apikey, nil)
    end

    def metric_group(group_name)
      @util.make_api_get_request("/metric_groups/#{group_name}.json", @apikey, nil)
    end

    def metric_names(group_name)
      # return an array of metric names in a metric group
      mgroup = self.metric_group(group_name)
      if !mgroup.nil?
        # go through each and add to array


      end
      puts "NOT YET IMPLEMENTED"
    end

    def create_metric_group(group_name, group_definition)
      @util.make_api_post_request("/metric_groups.json", @apikey, group_definition)
    end

    def dashboard(dashboard_name)
      dashes = @util.make_api_get_request("/dashboards.json", @apikey, nil)
      return nil if dashes.nil?

      # dashboards = JSON.parse(dashes.body)
      # modified 12-10-2012 ... get returns the body
      dashboards = JSON.parse(dashes)
      dashboards.each do |dash|
        if dash["name"] == dashboard_name
          return dash
        end
      end

      return nil
    end

    def create_dashboard(dashcfg)
      @util.make_api_post_request("/dashboards.json", @apikey, dashcfg)
    end

  end
end
