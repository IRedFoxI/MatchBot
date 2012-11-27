requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class ModeEvent < Kesh::IRC::Event
			
				def ModeEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length >= 4 && 
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ] == "MODE" 
					)
					
					source = tokens[ 0 ]
					target = tokens[ 2 ]					
					tokens.shift( 3 )
					
					if ( server.isChannel?( target ) )
						target = server.getChannelByName( target )
						modes = tokens[ 0 ]
						tokens.shift( 1 )
						channelModes = ChannelModeEvent.getChannelModeArrayFromString( target, modes, tokens )
						return ChannelModeEvent.new( server, source, target, channelModes )
					
					else
						target = server.getClientByName( target )
						clientModes = ClientModeEvent.getClientModeArrayFromString( target, tokens )
						return ClientModeEvent.new( server, source, target, clientModes )
					end
				end
				
			
				attr_reader :target
				attr_reader :modes
				
				def initialize( server, source, target, modes )
					super( server, source )
					Kesh::ArgTest::type( "target", target, [ Kesh::IRC::Client, Kesh::IRC::Channel ] )
					Kesh::ArgTest::type( "modes", modes, Array )
					@target = target
					@modes = modes
				end

			end
		
		end
	end
end