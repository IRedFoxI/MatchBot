requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class NoticeAuthEvent < Kesh::IRC::Event
			
				def NoticeAuthEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length == 3 &&
						tokens[ 0 ] == "NOTICE" &&
						tokens[ 1 ] == "AUTH"
					)
					
					return NoticeAuthEvent.new( server, tokens[ 2 ] )
				end
				
			
				attr_reader :message
				
				def initialize( server, message )
					super( server, server.serverClient )
					Kesh::ArgTest::type( "message", message, String )
					message.strip!()
					Kesh::ArgTest::stringLength( "message", message, 1 )
					@message = message
				end
				
			end
		
		end
	end
end