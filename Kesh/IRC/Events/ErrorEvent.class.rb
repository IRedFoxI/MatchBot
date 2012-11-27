requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class ErrorEvent < Kesh::IRC::Event
			
				def ErrorEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length == 2 &&
						tokens[ 0 ] == "ERROR"
					)
					
					return ErrorEvent.new( server, tokens[ 1 ] )
				end
				
			
				attr_reader :message
				
				def initialize( server, message )
					super( server, server.serverClient )
					Kesh::ArgTest::type( "message", message, String )
					Kesh::ArgTest::stringLength( "message", message, 1 )
					@message = message
				end
				
			end
		
		end
	end
end