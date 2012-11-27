requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class KickEvent < Kesh::IRC::Event
			
				def KickEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						( tokens.length == 3 || tokens.length == 4 ) &&
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ] == "KICK" 
					)
					
					channel = srever.getChannelByName( tokens[ 2 ] )
					target = server.getClientByName( tokens[ 3 ] )
					return KickEvent.new( server, tokens[ 0 ], channel, target, tokens[ 4 ] )
				end
				
			
				attr_reader :channel
				attr_reader :target
				attr_reader :message
				
				def initialize( server, source, channel, target, message )
					super( server, source )
					Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
					Kesh::ArgTest::type( "target", target, Kesh::IRC::Client )
					Kesh::ArgTest::type( "message", message, String )
					@channel = channel
					@target = target
					@message = message
				end
				
			end
		
		end
	end
end