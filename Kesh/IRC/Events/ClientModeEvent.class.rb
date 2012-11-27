requireLibrary '../../../IRC'
requireClass 'ModeEvent'

module Kesh
	module IRC
		module Events
		
			class ClientModeEvent < ModeEvent
			
				def initialize( server, source, target, modes )
					super( server, source, target, modes )
					Kesh::ArgTest::type( "target", target, Kesh::IRC::Client )
				end
				
			end
			
		
			def ClientModeEvent.getClientModeArrayFromString( client, tokens )
				Kesh::ArgTest::type( "client", client, Client )
				Kesh::ArgTest::type( "tokens", tokens, Array )
				Kesh::ArgTest::arraySize( "tokens", tokens, 1, 1 )
				
				clientModes = []
				status = false
				
				tokens[ 0 ].each_char do |char|
					if ( char == "+" )
						status = true
						
					elsif ( char == "-" )
						status = false
						
					else
						mode = client.server.getClientMode( char )
						
						if ( mode != nil )
							i = clientModes.index { |cm| cm.mode == mode }
							
							if ( i == nil )
								clientModes << ClientMode.new( client, mode, status )
	
							else
								clientModes[ i ].status = status
															
							end	
						end
					end
				end
				
				return clientModes
			end
					
		end
	end
end