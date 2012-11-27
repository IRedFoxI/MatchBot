requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class EndOfInfoNumeric < Kesh::IRC::Events::NumericEvent
				
					def EndOfInfoNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 1 &&
							id == RPL_ENDOFINFO
						)
						return EndOfInfoNumeric.new( server, source, id, target )
					end
					
				
					def initialize( server, source, id, target )
						super( server, source, id, target )
					end
					
				end
				
			end		
		end
	end
end