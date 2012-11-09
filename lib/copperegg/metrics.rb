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

      response = @util.make_api_post_request("/samples/#{group_name}.json", @apikey, payload)
      return
    end

    def samples(starttime, endtime, group_name, metricname)
      samples = @util.make_api_get_request("/samples.json", @apikey, nil)
      return samples
    end

    def metric_groups
      # return an array of metric groups
      mgroup = @util.make_api_get_request("/metric_groups.json", @apikey, nil)
      return mgroup
    end

    def metric_group(group_name)
      mgroup = @util.make_api_get_request("/metric_groups/#{group_name}.json", @apikey, nil)
      return mgroup
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
      response = @util.make_api_post_request("/metric_groups.json", @apikey, group_definition)
    end

    def dashboard(dashboard_name)
      dashes = @util.make_api_get_request("/dashboards.json", @apikey, nil)
      return nil if dashes.nil?

      dashboards = JSON.parse(dashes.body)
      dashboards.each do |dash|
        if dash["name"] == dashboard_name
          return dash
        end
      end

      return nil
    end

    def create_dashboard(dashcfg)
      response = @util.make_api_post_request("/dashboards.json", @apikey, dashcfg)
    end

    private


  end
end
