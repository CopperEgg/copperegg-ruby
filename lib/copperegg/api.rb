module CopperEgg
	class Api
		class << self
			attr_accessor :apikey
			attr_reader :ssl_verify_peer, :timeout

			def host=(host)
				@uri = URI.join(host, "/v2/revealmetrics/").to_s
			end

			def uri
				@uri || "https://api.copperegg.com/v2/revealmetrics/"
			end

			def ssl_verify_peer=(boolean)
				@ssl_verify_peer = boolean ? true : false
			end

			def timeout=(seconds)
				@timeout = seconds.to_i
			end
		end
	end
end