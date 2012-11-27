requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class NoneNumeric < Kesh::IRC::Events::NumericEvent
				
					def NoneNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							id == RPL_NONE
						)
						return NoneNumeric.new( server, source, id, target )
					end
					
				
					def initialize( server, source, id, target )
						super( server, source, id, target )
					end
					
				end
				
			end		
		end
	end
end