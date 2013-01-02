module CopperEgg
	class Api
		class << self
			attr_accessor :apikey
			attr_reader :ssl_verify_peer, :timeout

			@uri = "https://api.copperegg.com/v2/revealmetrics/"

			def host=(host)
				@uri = "#{host}/v2/revealmetrics/"
			end

			def uri
				@uri
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