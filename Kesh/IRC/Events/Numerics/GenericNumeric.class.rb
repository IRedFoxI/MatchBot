requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
	
				class GenericNumeric < Kesh::IRC::Events::NumericEvent
				
					attr_reader :tokens
					
					def initialize( server, source, id, target, tokens )
						super( server, source, id, target )
						Kesh::ArgTest::type( "tokens", tokens, Array )
						@tokens = tokens
					end
					
				end
				
			end			
		end				
	end
end