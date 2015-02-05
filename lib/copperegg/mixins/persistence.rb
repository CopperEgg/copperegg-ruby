module CopperEgg
	class ValidationError < Exception; end

	class HttpError < Exception; end

	module Mixins
		module Persistence
			def self.included(klass)
				klass.class_eval do
					class << self
						attr_reader :resource_name

						def find(*args)
							params = args.last.class == Hash ? args.pop : {}
							id = args.first
							response = request(params.merge(:request_type => "get", :id => id))
							if response.code == "200"
								json = JSON.parse(response.body)
								if json.is_a?(Array)
									json.map {|attributes| new(attributes)}
								else
									new(json)
								end
							end
						end

						def create(params)
							params.delete(:id)
							params.delete("id")
							new(params).save
						end

						def delete(id)
							request(:id => id, :request_type => "delete")
						end

						def request(params={})
							request_type = params.delete(:request_type)
							raise "invalid type `#{request_type}`" if !%w(get post put delete).include?(request_type)
							id = params.delete(:id)

							uri = id ? URI.parse("#{Api.uri}/#{self.resource_name}/#{id}.json") : URI.parse("#{Api.uri}/#{self.resource_name}.json")

							http = Net::HTTP.new(uri.host, uri.port)
							http.use_ssl = uri.scheme == 'https'
				      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if !Api.ssl_verify_peer

				      request = Net::HTTP.const_get(request_type.capitalize).new(uri.request_uri)
				      request.body = JSON.generate(params) unless params.empty?
				      request.basic_auth(Api.apikey, "U")
				      request["Content-Type"] = "application/json"

				      begin
				        response = http.request(request)
				      rescue Exception => e
				         raise e
				      end

				      response
						end

						def request_200(params={})
							response = request(params)
							unless response.code === "200"
								raise HttpError.new("HTTP request failed with code `#{response.code}`: `#{response.body}`")
							end
							response
						end

						private

						def resource(value)
							@resource_name = value
						end
					end
				end
			end

			attr_reader :id, :error

			def initialize(attributes={})
				load_attributes(attributes)
			end

			def save
				if valid?
					response = persisted? ? update : create
					attributes = JSON.parse(response.body)
					if response.code != "200"
						@error = attributes.merge("code" => response.code)
					else
						load_attributes(attributes)
					end
				else
					raise ValidationError.new(@error)
				end
			end

			def delete
				self.class.request(:id => @id, :request_type => "delete")
			end

			def persisted?
				!@id.nil?
			end

			private

			def create
				self.class.request(to_hash.merge(:request_type => "post"))
			end

			def update
				self.class.request(to_hash.merge(:id => @id, :request_type => "put"))
			end
		end
	end
end
