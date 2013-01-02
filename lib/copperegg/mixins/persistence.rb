module CopperEgg
	class ValidationError < Exception; end

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
							if response && response.is_a?(Array)
								response.map {|resp| new(resp)}
							elsif response
								new(response)
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

						private

						def resource(value)
							@resource_name = value
						end

						def request(params={})
							request_type = params.delete(:request_type)
							raise "invalid type" if !%w(get post put delete).include?(request_type)
							id = params.delete(:id)

							uri = id ? URI.parse("#{Api.uri}/#{self.resource_name}/#{id}.json") : URI.parse("#{Api.uri}/#{self.resource_name}.json")

							http = Net::HTTP.new(uri.host, uri.port)
							http.use_ssl = uri.scheme == 'https'
				      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if !Api.ssl_verify_peer

				      request = Net::HTTP.const_get(request_type.capitalize).new(uri.request_uri)
				      request.body = JSON.generate(params) unless params.empty?
				      request.basic_auth(Api.apikey, "U")
				      request["Content-Type"] = "application/json"

				      connect_try_count = 0
				      response = nil
				      begin
				        response = http.request(request)
				      rescue Exception => e
				        connect_try_count += 1
				        if connect_try_count > 1
				          log "#{e.inspect}"
				          raise e
				        end
				        sleep 0.5
				        retry
				      end

				      return nil if response.nil? || response.code != "200" || response.body.nil? || response.body.strip.empty?

				      JSON.parse(response.body)
						end
					end
				end
			end

			attr_reader :id

			def save
				if valid?
					attributes = persisted? ? create : update
					parse_attributes(attributes)
				else
					raise ValidationError.new(@error)
				end
			end

			def delete
				self.class.request(:id => @id, :request_type => "delete").nil?
			end

			private

			def create
				self.class.request(to_hash.merge(:request_type => "post"))
			end

			def update
				self.class.request(to_hash.merge(:id => @id, :request_type => "put"))
			end

			def persisted?
				@id.nil?
			end
		end
	end
end
