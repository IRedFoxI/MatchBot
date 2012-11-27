requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class ListEndNumeric < Kesh::IRC::Events::NumericEvent
				
					def ListEndNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_LISTEND
						)
						return ListEndNumeric.new( server, source, id, target )
					end
					
				
					def initialize( server, source, id, target )
						super( server, source, id, target )
					end
					
				end
				
			end		
		end
	end
end