requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class LUserUnknownNumeric < Kesh::IRC::Events::NumericEvent
				
					def LUserUnknownNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_LUSERUNKNOWN
						)
						
						return LUserUnknownNumeric.new( server, source, id, target, Integer( tokens[ 0 ] ) )
					end
					
				
					attr_reader :unknownConnections
				
					def initialize( server, source, id, target, unknownConnections )
						super( server, source, id, target )
						Kesh::ArgTest::type( "unknownConnections", unknownConnections, Fixnum )
						@unknownConnections = unknownConnections
					end
					
				end
				
			end		
		end
	end
end