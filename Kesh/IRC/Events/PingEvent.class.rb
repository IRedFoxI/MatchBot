requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class PingEvent < Kesh::IRC::Event
			
				def PingEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length == 2 &&
						tokens[ 0 ] == "PING" 
					)
					
					return PingEvent.new( server, tokens[ 1 ] )
				end
				
			
				attr_reader :token
				
				def initialize( server, token )
					super( server, server.serverClient )
					Kesh::ArgTest::type( "token", token, String )
					Kesh::ArgTest::stringLength( "token", token, 1 )
					@token = token
				end
				
			end
		
		end
	end
end