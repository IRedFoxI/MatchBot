requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class NotRegisteredNumeric < Kesh::IRC::Events::NumericEvent
				
					def NotRegisteredNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 1 &&
							id == ERR_NOTREGISTERED
						)
						return NotRegisteredNumeric.new( server, source, id, target )
					end
					
				
					def initialize( server, source, id, target )
						super( server, source, id, target )
					end
					
				end
				
			end		
		end
	end
end