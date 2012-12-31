module CopperEgg
	class CustomDashboard < ActiveResource::Base
		include ActiveModel::Validations
		include CopperEgg::Mixins::Resources
		extend ActiveModel::Callbacks

		self.element_name = "dashboard"

		validates_each :data do |record, attr, data|
			data.widgets.values.each do |widget|
				widget = Widget.new(widget) if widget.is_a?(Hash)
				if !widget.is_a?(Widget)
	  			record.errors.add(attr, "widget expected.")
	  		elsif !widget.valid?
	  			record.errors.add(attr, widget.error)
	  		end
			end
		end

		validates_each :name do |record, attr, value|
			record.errors.add(attr, "can't be blank") if value.blank?
		end

		define_model_callbacks :save, :only => [:before]
		before_save :set_data_order

		class <<self
			def create(*args)
				options = args.extract_options!.with_indifferent_access

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
					widget = Widget.new(:type => widget_type, :style => widget_style, :match => widget_match, :metric => {metric_group.name => [[metric.position, metric.name]]})
					widget.match_param = identifiers if identifiers
					dashboard.data.widgets[i.to_s] = widget
				end
				dashboard.save
				dashboard
			end

			def find_by_name(name)
				all.find {|dashboard| dashboard.name == name}
			end

			private

			def filter_metrics(metric_group, specified_metrics)
				metrics = metric_group.metrics.map(&:name)
				specified_metrics = specified_metrics.is_a?(Array) ? specified_metrics & metrics : (specified_metrics ? [specified_metrics] & metrics : [])
				specified_metrics.empty? ? metrics : specified_metrics
			end
		end

		def initialize(*args)
	  	super(*args)
	  	@attributes["name"] = nil if !@attributes["name"]
	  	@attributes["data"] = Data.new if !@attributes["data"]
	  end

	  def save
		  run_callbacks(:save) { super }
		end

		protected

		def set_data_order
			data.set_order
		end

	  class Data
	  	attr_accessor :widgets
	  	attr_reader :order

	  	def initialize(attributes={})
	  		attributes = attributes.with_indifferent_access
	  		@widgets = attributes[:widgets] || {}
	  		@widgets.each { |index, hash| @widgets[index] = Widget.new(hash) }
	  		@order = attributes[:order] || []
	  	end

	  	def set_order
	  		@order = @widgets.keys
	  	end

	  	def to_json(options={})
		  	as_json(options.merge(:root => false)).to_json
		  end
	  end

		class Widget
			TYPES = %w(metric metric_list timeline)
			STYLES = %w(value timeline both list values)
			MATCHES = %w(select multi tag all)

			attr_accessor :type, :style, :match, :match_param, :metric, :label
			attr_reader :error

			def initialize(attributes={})
				attributes.delete(:error)
				attributes.each {|attr, value| send("#{attr}=", value)}
				@error = nil
			end

			def valid?
				valid = false
				if !TYPES.include?(self.type)
					@error = "Invalid widget type #{self.type}."
				elsif !STYLES.include?(self.style)
					@error = "Invalid widget style #{self.style}."
				elsif !MATCHES.include?(self.match)
					@error = "Invalid widget match #{self.match}."
				elsif !self.metric.is_a?(Hash) || self.metric.keys.size == 0
					@error = "Invalid widget metric."
				elsif self.match != "all" && self.match_param.blank?
					@error = "Missing match parameter."
				else
					self.metric.each do |metric_group_name, value|
						if !value.is_a?(Array)
							@error = "Invalid widget metric."
						elsif value.length == 0
							@error = "Invalid widget metric."
						else
							value.each do |metric_data|
								if !metric_data.is_a?(Array)
									@error = "Invalid widget metric."
								elsif metric_data.length < 2
									@error = "Invalid widget metric."
								elsif (/^\d+$/ =~ metric_data.first.to_s).nil?
									@error = "Invalid widget metric."
								end
							end
						end
					end
				end

				if @error.nil?
					valid = true
					self.match_params = [self.match_param] if self.match != "all" && !self.match_param.is_a?(Array)
					remove_instance_variable(:@error) if instance_variable_get(:@error)
				end
				
				valid
			end

			def to_json(options={})
		  	as_json(options.merge(:root => false)).to_json
		  end
		end
	end
end
