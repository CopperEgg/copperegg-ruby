module CopperEgg
	module Mixins
		module Attributes
			def initialize(attributes={})
				parse_attributes(attributes)
			end

			def parse_attributes(attributes)
				attributes.each do |name, value|
					if name.to_s == "id"
						@id = value
					elsif !respond_to?("#{name}=")
						next
					else
						if value.is_a?(Hash) && self.class.const_defined?(name.to_s.capitalize)
							send "#{name}=", self.class.const_get(name.to_s.capitalize).new(value)
						elsif value.is_a?(Array) && value.first.is_a?(Hash) && self.class.const_defined?(name.to_s.sub(/s$/,"").capitalize)
							send "#{name}=", value.map { |v| self.class.const_get(name.to_s.sub(/s$/,"").capitalize).new(v) }
						else
							send "#{name}=", value
						end
					end
				end
			end

			def to_hash
				self.instance_variables.reduce({}) do |memo, variable|
					unless variable == :@error
						value = instance_variable_get(variable)
						if value.is_a?(Hash)
							value = value.reduce({}) {|memo, value| memo[value.first] = value.last.respond_to?(:to_hash) ? value.last.to_hash : value.last; memo}
						elsif value.respond_to?(:to_hash)
							value = value.to_hash
						elsif value.is_a?(Array)
							value = value.map {|v| v.respond_to?(:to_hash) ? v.to_hash : v}
						end
						memo[variable.to_s.sub("@","")] = value
					end
					memo
				end
			end
		end
	end
end
