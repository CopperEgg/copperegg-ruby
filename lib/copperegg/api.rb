module CopperEgg
	class Api
		def self.host=(host)
			MetricGroup.site = MetricSample.site = CustomDashboard.site = "#{host}/v2/revealmetrics"
		end

		def self.apikey=(apikey)
			MetricGroup.user = MetricSample.user = CustomDashboard.user = apikey
		end
	end
end