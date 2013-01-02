module CopperEgg
	class MetricGroup
		include CopperEgg::Mixins::Persistence
		include CopperEgg::Mixins::Attributes
		
		resource "metric_groups"

		attr_accessor :name, :label, :frequency, :metrics

		alias_method :orig_parse_attributes, :parse_attributes

		def parse_attributes(attributes)
			orig_parse_attributes(attributes)
			@metrics ||= []
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

	  class Metric
	  	include CopperEgg::Mixins::Attributes

	  	TYPES = %w(ce_gauge ce_gauge_f ce_counter ce_counter_f)

			attr_accessor :name, :label, :type, :unit
			attr_reader :error, :position

			alias_method :orig_parse_attributes, :parse_attributes

			def parse_attributes(attributes)
				@position = attributes.delete(:position) || attributes.delete("position")
				orig_parse_attributes(attributes)
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
