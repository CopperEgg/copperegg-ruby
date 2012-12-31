module CopperEgg
	module Mixins
		module Resources
			def self.included(klass)
				klass.class_eval do
				  self.site = "https://api.copperegg.com/v2/revealmetrics"
				  
					def self.find(*args)
						begin
							super(*args)
						rescue ActiveResource::ForbiddenAccess
							return
						end
					end
				end
			end

		  def to_json(options={})
		  	as_json(options.merge(:root => false)).to_json(options.merge(:root => false))
		  end

		  # create settors and accessors for values in the @attributes hash
		  def method_missing(meth, *args, &block)
		  	str = meth.id2name
		  	if @attributes[str]
		  		return @attributes[str]
		  	elsif @attributes[str.sub("=","")]
		  		return @attributes[str.sub("=","")] = args.first
		  	end
		  	super(meth, *args, &block)
		  end
		end
	end
end