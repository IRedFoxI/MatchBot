requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class PrivMsgEvent < Kesh::IRC::Event
			
				def PrivMsgEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length == 4 && 
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ] == "PRIVMSG" 
					)

					target = server.isChannel?( tokens[ 2 ] ) ? server.getChannelByName( tokens[ 2 ] ) : server.getClientByName( tokens[ 2 ] )
					return ActionMsgEvent.new( server, tokens[ 0 ], target, tokens[ 3 ][ 1..-2 ] ) if ( tokens[ 3 ][ 0 ] == 1.chr && tokens[ 3 ][ -1 ] == 1.chr )
					return PrivMsgEvent.new( server, tokens[ 0 ], target, tokens[ 3 ] )
				end
				
			
				attr_reader :target
				attr_reader :message
				
				def initialize( server, source, target, message )
					super( server, source )
					Kesh::ArgTest::type( "target", target, [ Kesh::IRC::Client, Kesh::IRC::Channel ] )
					Kesh::ArgTest::type( "message", message, String )
					@target = target
					@message = message
				end
				
			end
		
		end
	end
end