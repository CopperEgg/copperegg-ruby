module CopperEgg
  class MetricSample
    include CopperEgg::Mixins::Persistence
  	
    resource "samples"

  	def self.save(group_name, identifier, timestamp, metric_values)
      request(:id => group_name, :identifier => identifier, :timestamp => timestamp, :values => metric_values, :request_type => "post")
    end

    def self.samples(group_name, metrics, starttime=nil, duration=nil, sample_size=nil)
      metrics = [metrics] unless metrics.is_a?(Array)
      params = {}
      params[:starttime] = starttime if starttime
      params[:duration] = duration if duration
      params[:sample_size] = sample_size if sample_size
      params[:queries] = {group_name => [{:metrics => metrics}]}

      request(params.merge(:request_type => "get"))
    end
  end
end
