module CopperEgg
  class MetricSample < ActiveResource::Base
    include CopperEgg::Mixins::Resources
  	self.element_name = "sample"

  	def self.save(group_name, identifier, timestamp, metric_values)
      sample = new(:identifier => identifier, :timestamp => timestamp, :values => metric_values)
      sample.post(group_name)
    end

    def self.samples(group_name, metrics, starttime=nil, duration=nil, sample_size=nil)
      metrics = [metrics] unless metrics.is_a?(Array)
      params = {}
      params[:starttime] = starttime if starttime
      params[:duration] = duration if duration
      params[:sample_size] = sample_size if sample_size
      params[:queries] = {group_name => [{:metrics => metrics}]}

      prefix_options, query_options = split_options(params)
      path = collection_path(prefix_options, query_options)
      connection.get(path, headers).body
    end

  	def initialize(*args)
  		super(*args)
  		@persisted = true
  	end

    class Values
      def to_json(options={})
        as_json(options.merge(:root => false)).to_json
      end
    end
  end
end
