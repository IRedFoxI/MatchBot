requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class ServerDetailsNumeric < Kesh::IRC::Events::NumericEvent
				
					def ServerDetailsNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 5 &&
							id == RPL_MYINFO							
						)						
						return ServerDetailsNumeric.new( server, source, id, target, tokens[ 0 ], tokens[ 1 ], tokens[ 2 ], tokens[ 3 ], tokens[ 4 ] )
					end
					
				
					attr_reader :host
					attr_reader :version
					attr_reader :clientModes
					attr_reader :channelModes
					attr_reader :channelModesWithParameter
					
					def initialize( server, source, id, target, host, version, clientModes, channelModes, channelModesWithParameter )
						super( server, source, id, target )
						Kesh::ArgTest::type( "host", host, String )
						Kesh::ArgTest::type( "version", version, String )
						Kesh::ArgTest::type( "clientModes", clientModes, String )
						Kesh::ArgTest::type( "channelModes", channelModes, String )
						Kesh::ArgTest::type( "channelModesWithParameter", channelModesWithParameter, String )
						@host = host
						@version = version
						@clientModes = clientModes
						@channelModes = channelModes
						@channelModesWithParameter = channelModesWithParameter
					end
					
				end
				
			end		
		end
	end
end