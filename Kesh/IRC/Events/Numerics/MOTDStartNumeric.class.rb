requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class MOTDStartNumeric < Kesh::IRC::Events::NumericEvent
				
					def MOTDStartNumeric.parse( server, source, id, target, tokens )
						return nil unless ( 
							tokens.length == 1 &&
							id == RPL_MOTDSTART 
						)
						return MOTDStartNumeric.new( server, source, id, target )
					end

				end
				
			end		
		end
	end
end