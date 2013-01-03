module CopperEgg
	class CustomDashboard
		include CopperEgg::Mixins::Persistence

		WIDGET_TYPES 		= %w(metric metric_list timeline)
		WIDGET_STYLES 	= %w(value timeline both list values)
		WIDGET_MATCHES	= %w(select multi tag all)
	
		resource "dashboards"

		attr_accessor :name, :label, :data

		def initialize(attributes={})
			load_attributes(attributes)
		end

		def load_attributes(attributes)
			@data = {"widgets" => {}, "order" => []}
			attributes.each do |name, value|
				if name.to_s == "id"
					@id = value
				elsif name.to_s == "data"
					attributes[name].each do |data_name, data_value|
						if data_name.to_s == "order"
							data["order"] = data_value
						else
							data["widgets"] = data_value
						end
					end
				elsif !respond_to?("#{name}=")
					next
				else
					send "#{name}=", value
				end
			end
		end

		def valid?
			@error = nil
			if self.name.nil? || self.name.to_s.strip.empty?
				@error = "Name can't be blank."
			else
				self.data["widgets"].values.each do |widget|
					widget.each do |key, value|
						if key.to_s == "type" && !WIDGET_TYPES.include?(value)
							@error = "Invalid widget type #{value}."
						elsif key.to_s == "style" && !WIDGET_STYLES.include?(value)
							@error = "Invalid widget style #{value}."
						elsif key.to_s == "match" && !WIDGET_MATCHES.include?(value)
							@error = "Invalid widget match #{value}."
						elsif key.to_s == "metric" && (!value.is_a?(Hash) || value.keys.size == 0)
							@error = "Invalid widget metric. #{value}"
						elsif key.to_s == "match_param" && (widget["match"] || widget[:match]) != "all" && (value.nil? || value.to_s.strip.empty?)
							@error = "Missing match parameter."
						else
							(widget["metric"] || widget[:metric]).each do |metric_group_name, metric_group_value|
								if !metric_group_value.is_a?(Array)
									@error = "Invalid widget metric. #{metric_group_value}"
								elsif metric_group_value.length == 0
									@error = "Invalid widget metric. #{metric_group_value}"
								else
									metric_group_value.each do |metric_data|
										if !metric_data.is_a?(Array)
											@error = "Invalid widget metric. #{metric_group_value}"
										elsif metric_data.length < 2
											@error = "Invalid widget metric. #{metric_group_value}"
										elsif (/^\d+$/ =~ metric_data.first.to_s).nil?
											@error = "Invalid widget metric. #{metric_group_value}"
										end
									end
								end
							end
						end
					end
					break if !@error.nil?
				end
			end
			@error.nil?
		end

		def to_hash
			set_data_order
			self.instance_variables.reduce({}) do |memo, variable|
				unless variable.to_s == "@error"
					value = instance_variable_get(variable)
					memo[variable.to_s.sub("@","")] = value
				end
				memo
			end
		end

		class <<self
			def create(*args)
				options = args.last.class == Hash ? args.pop : {}

				return super(args.first) if args.first.is_a?(Hash)

				metric_group = args.first
				raise ArgumentError.new("CopperEgg::MetricGroup object expected") if !metric_group.is_a?(MetricGroup)
				raise ArgumentError.new("Invalid metric group") if !metric_group.valid?

				metrics 			= filter_metrics(metric_group, options[:metrics]).map { |name| metric_group.metrics.find {|metric| metric.name == name} }
				identifiers 	= options[:identifiers].is_a?(Array) ? (options[:identifiers].empty? ? nil : options[:identifiers]) : (options[:identifier] ? [options[:identifiers]] : nil)
				widget_match 	= identifiers.nil? ? "all" : (identifiers.size == 1 ? "select" : "multi")
				widget_type 	= widget_match == "select" ? "metric" : "timeline"
				widget_style 	= widget_type == "metric" ? "both" : "values"
				name 					= options[:name] || "#{metric_group.label} Dashboard"

				dashboard = new(:name => name)
				metrics.each.with_index do |metric, i|
					metric_data = [metric.position, metric.name]
					metric_data.push("rate") if metric.type == "ce_counter" || metric.type == "ce_counter_f"
					widget = {:type => widget_type, :style => widget_style, :match => widget_match, :metric => {metric_group.name => [metric_data]}}
					widget[:match_param] = identifiers if identifiers
					dashboard.data["widgets"][i.to_s] = widget
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

		private

		def set_data_order
  		@data["order"] = @data["widgets"].keys if @data["order"].empty?
  	end
	end
end
