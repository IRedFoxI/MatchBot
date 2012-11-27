requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class UModeIsNumeric < Kesh::IRC::Events::NumericEvent
				
					def UModeIsNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 1 &&
							id == RPL_UMODEIS
						)
						
						modeArray = Kesh::IRC::Events::ClientModeEvent.getClientModeArrayFromString( server.myClient, tokens )
						
						return UModeIsNumeric.new( server, source, id, target, modeArray )
					end
					
				
					attr_reader :modeArray
				
					def initialize( server, source, id, target, modeArray )
						super( server, source, id, target )
						Kesh::ArgTest::type( "modeArray", modeArray, Array )
						@modeArray = modeArray
					end
					
				end
				
			end		
		end
	end
end