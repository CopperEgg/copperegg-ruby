module CopperEgg
	class CustomDashboard
		include CopperEgg::Mixins::Persistence
		include CopperEgg::Mixins::Attributes
	
		resource "dashboards"

		attr_accessor :name, :label, :data

		alias_method :orig_parse_attributes, :parse_attributes

		def parse_attributes(attributes)
			orig_parse_attributes(attributes)
			@data ||= Data.new
		end

		def valid?
			@error = nil
			if self.name.nil? || self.name.to_s.strip.empty?
				@error = "Name can't be blank."
			else
				self.data.widgets = self.data.widgets.reduce({}) {|memo, value| memo[value.first] = value.last.is_a?(Hash) ? Widget.new(value.last) : value.last; memo}
				self.data.widgets.values.each do |widget|
					widget = Widget.new(widget) if widget.is_a?(Hash)
					if !widget.is_a?(Widget)
		  			@error = "Widget expected."
		  			break
		  		elsif !widget.valid?
		  			@error = widget.error
		  			break
		  		end
				end
			end
			@error.nil?
		end

		class <<self
			def create(*args)
				options = args.last.class == Hash ? args.pop : {}

				return super(args.first) if args.first.is_a?(Hash)

				metric_group = args.first
				raise ArgumentError.new("CopperEgg::MetricGroup object expected") if !metric_group.is_a?(MetricGroup)
				raise ArgumentError.new("Invalid metric group") if !metric_group.valid?

				name 					= options[:name] || "#{metric_group.label} Dashboard"
				metrics 			= filter_metrics(metric_group, options[:metrics]).map { |name| metric_group.metrics.find {|metric| metric.name == name} }
				identifiers 	= options[:identifiers].is_a?(Array) ? (options[:identifiers].empty? ? nil : options[:identifiers]) : (options[:identifier] ? [options[:identifiers]] : nil)
				widget_match 	= identifiers.nil? ? "all" : (identifiers.size == 1 ? "select" : "multi")
				widget_type 	= widget_match == "select" ? "metric" : "timeline"
				widget_style 	= widget_type == "metric" ? "both" : "values"

				dashboard = new(:name => name)
				metrics.each.with_index do |metric, i|
					metric_data = [metric.position, metric.name]
					metric_data.push("rate") if metric.type == "ce_counter" || metric.type == "ce_counter_f"
					widget = Widget.new(:type => widget_type, :style => widget_style, :match => widget_match, :metric => {metric_group.name => [metric_data]})
					widget.match_param = identifiers if identifiers
					dashboard.data.widgets[i.to_s] = widget
				end
				dashboard.save
				dashboard
			end

			def find_by_name(name)
				find.detect {|dashboard| dashboard.name == name}
			end

			private

			def filter_metrics(metric_group, specified_metrics)
				metrics = metric_group.metrics.map(&:name)
				specified_metrics = specified_metrics.is_a?(Array) ? specified_metrics & metrics : (specified_metrics ? [specified_metrics] & metrics : [])
				specified_metrics.empty? ? metrics : specified_metrics
			end
		end

	  class Data
	  	include CopperEgg::Mixins::Attributes

	  	attr_accessor :widgets
	  	attr_reader :order, :error

	  	def initialize(attributes={})
	  		@widgets = attributes[:widgets] || attributes["widgets"] || {}
	  		@widgets.each { |index, hash| @widgets[index] = Widget.new(hash) }
	  		@order = attributes[:order] || []
	  	end

	  	def set_order
	  		@order = @widgets.keys if @order.empty?
	  	end

	  	alias_method :orig_to_hash, :to_hash

	  	def to_hash
	  		set_order
	  		orig_to_hash
	  	end
	  end

		class Widget
			include CopperEgg::Mixins::Attributes

			TYPES = %w(metric metric_list timeline)
			STYLES = %w(value timeline both list values)
			MATCHES = %w(select multi tag all)

			attr_accessor :type, :style, :match, :match_param, :metric, :label
			attr_reader :error

			def valid?
				valid = false
				@error = nil
				if !TYPES.include?(self.type)
					@error = "Invalid widget type #{self.type}."
				elsif !STYLES.include?(self.style)
					@error = "Invalid widget style #{self.style}."
				elsif !MATCHES.include?(self.match)
					@error = "Invalid widget match #{self.match}."
				elsif !self.metric.is_a?(Hash) || self.metric.keys.size == 0
					@error = "Invalid widget metric. #{self.metric}"
				elsif self.match != "all" && (self.match_param.nil? || self.match_param.to_s.strip.empty?)
					@error = "Missing match parameter."
				else
					self.metric.each do |metric_group_name, value|
						if !value.is_a?(Array)
							@error = "Invalid widget metric. #{self.metric}"
						elsif value.length == 0
							@error = "Invalid widget metric. #{self.metric}"
						else
							value.each do |metric_data|
								if !metric_data.is_a?(Array)
									@error = "Invalid widget metric. #{self.metric}"
								elsif metric_data.length < 2
									@error = "Invalid widget metric. #{self.metric}"
								elsif (/^\d+$/ =~ metric_data.first.to_s).nil?
									@error = "Invalid widget metric. #{self.metric}"
								end
							end
						end
					end
				end

				if @error.nil?
					valid = true
					self.match_params = [self.match_param] if self.match != "all" && !self.match_param.is_a?(Array)
					remove_instance_variable(:@error)
				end
				
				valid
			end
		end
	end
end
