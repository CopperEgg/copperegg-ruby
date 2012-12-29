module CopperEgg
	class MetricGroup < ActiveResource::Base
		include ActiveModel::Validations
		include CopperEgg::Mixins::Resources

	  validates_presence_of :name
	  validates_length_of :metrics, :minimum => 1, :allow_nil => false, :allow_blank => false, :message => "You must define at least one metric."

	  validates_each :metrics do |record, attr, value|
	  	value.each do |metric|
	  		metric = Metric.new(metric) if metric.is_a?(Hash)
	  		if !metric.is_a?(Metric)
	  			record.errors.add(attr, "Metric expected.")
	  		elsif !metric.valid?
	  			record.errors.add(attr, metric.error)
	  		elsif record.new?
	  			metric.send(:remove_instance_variable, :@position) if metric.instance_variable_get(:@position)
	  		end
	  	end
	  end

	  def initialize(*args)
	  	super(*args)
	  	@attributes["name"] = nil if !@attributes["name"]
	  	@attributes["metrics"] = [] if !@attributes["metrics"]
	  end

	  class Metric
	  	TYPES = %w(ce_gauge ce_gauge_f ce_counter ce_counter_f)

			attr_accessor :name, :label, :type, :unit
			attr_reader :error, :position

			def initialize(attributes = {})
				attributes = attributes.with_indifferent_access
				@position = attributes.delete(:position)
				attributes.each { |attr, value| send("#{attr}=", value) }
				@error = nil
			end

			def valid?
				valid = false
				if self.name.blank?
					@error = "Metric name cannot be blank."
				elsif self.type.blank?
					@error = "Metric type must be defined."
				elsif !TYPES.include?(self.type)
					@error = "Invalid metric type #{self.type}."
				else
					valid = true
					remove_instance_variable(:@error) if @error
				end
				valid
			end
	  end
	end
end
