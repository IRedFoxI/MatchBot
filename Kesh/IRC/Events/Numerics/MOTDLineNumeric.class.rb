requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class MOTDLineNumeric < Kesh::IRC::Events::NumericEvent
				
					def MOTDLineNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 1 &&
							id == RPL_MOTD					
						)							
						return MOTDLineNumeric.new( server, source, id, target, tokens[ 0 ] )
					end
					
				
					attr_reader :line
					
					def initialize( server, source, id, target, line )
						super( server, source, id, target )
						Kesh::ArgTest::type( "line", line, String )
						@line = line
					end
					
				end
				
			end		
		end
	end
end