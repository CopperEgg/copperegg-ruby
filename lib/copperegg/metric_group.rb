module CopperEgg
	class MetricGroup
		include CopperEgg::Mixins::Persistence
		
		resource "metric_groups"

		attr_accessor :name, :label, :frequency, :metrics

		def load_attributes(attributes)
			@metrics = []
			attributes.each do |name, value|
				if name.to_s == "id"
					@id = value
				elsif !respond_to?("#{name}=")
					next
				elsif value.to_s == "metrics"
					@metrics = value.map {|v| Metric.new(v)}
				else
					send "#{name}=", value
				end
			end
		end

		def to_hash
			self.instance_variables.reduce({}) do |memo, variable|
				value = instance_variable_get(variable)
				if variable.to_s == "@metrics"
					memo[variable.to_s.sub("@","")] = value.map(&:to_hash)
				elsif variable.to_s != "@error"
					memo[variable.to_s.sub("@","")] = value
				end
				memo
			end
		end

	  def valid?
	  	@error = nil
	  	if self.name.nil? || self.name.to_s.strip.empty?
	  		@error = "Name can't be blank."
	  	elsif self.metrics.nil? || self.metrics.empty?
	  		@error = "You must define at least one metric."
	  	else
	  		self.metrics = self.metrics.map {|metric| metric.is_a?(Hash) ? Metric.new(metric) : metric}
		  	self.metrics.each do |metric|
		  		if !metric.is_a?(Metric)
		  			@error = "Metric expected."
		  			break
		  		elsif !metric.valid?
		  			@error = metric.error
		  			break
		  		else
		  			metric.send(:remove_instance_variable, :@position) if (metric.instance_variables.include?(:@position) || metric.instance_variables.include?("@position")) && !self.persisted?
		  		end
		  	end
		  end
		  @error.nil?
	  end

	  private

		def create
			response = self.class.request(:request_type => "get", :id => self.name, :show_hidden => true)
			if response.code == "200"
				json = JSON.parse(response.body)
				metric_group = self.class.new(json)
				@id = self.name
				# needs_update = self.label != metric_group.label || self.frequency != metric_group.frequency || self.metrics.length != metric_group.metrics.length || self.metrics.map(&:name).sort != metric_group.metrics.map {|m| m["name"]}.sort
				if true #needs_update
					self.class.request(self.to_hash.merge(:id => @id, :is_hidden => 0, :request_type => "put", :show_hidden => true))
				else
					response
				end
			else
				self.class.request(self.to_hash.merge(:request_type => "post"))
			end
		end

	  class Metric
	  	TYPES = %w(ce_gauge ce_gauge_f ce_counter ce_counter_f)

			attr_accessor :name, :label, :type, :unit
			attr_reader :error, :position

			def initialize(attributes={})
				attributes.each do |name, value|
					if name.to_s == "position"
						@position = value
					elsif !respond_to?("#{name}=")
						next
					else
						send "#{name}=", value
					end
				end
			end

			def to_hash
				self.instance_variables.reduce({}) do |memo, variable|
					if variable.to_s != "@error"
						value = instance_variable_get(variable)
						memo[variable.to_s.sub("@","")] = value
					end
					memo
				end
			end

			def valid?
				valid = false
				@error = nil
				if self.name.nil? || self.name.to_s.strip.empty?
					@error = "Metric name cannot be blank."
				elsif self.type.nil? || self.type.to_s.strip.empty?
					@error = "Metric type must be defined."
				elsif !TYPES.include?(self.type)
					@error = "Invalid metric type #{self.type}."
				else
					valid = true
					remove_instance_variable(:@error)
				end
				valid
			end
	  end
	end
end
