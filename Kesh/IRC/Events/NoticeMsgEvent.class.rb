requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class NoticeMsgEvent < Kesh::IRC::Event
			
				def NoticeMsgEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length == 4 && 
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ] == "NOTICE" 
					)
					
					target = server.isChannel?( tokens[ 2 ] ) ? server.getChannelByName( tokens[ 2 ] ) : server.getClientByName( tokens[ 2 ] )
					return CTCPMsgEvent.new( server, tokens[ 0 ], target, tokens[ 3 ][1..-2] ) if ( tokens[ 3 ][ 0 ] == 1.chr && tokens[ 3 ][ -1 ] == 1.chr )
					return NoticeMsgEvent.new( server, tokens[ 0 ], target, tokens[ 3 ] )
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