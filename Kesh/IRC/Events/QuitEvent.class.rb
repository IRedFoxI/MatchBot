requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class QuitEvent < Kesh::IRC::Event
			
				def QuitEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						( tokens.length == 2 || tokens.length == 3 ) &&
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ] == "QUIT" 
					)

					return QuitEvent.new( server, tokens[ 0 ], tokens[ 2 ] )
				end
				
			
				attr_reader :message
				
				def initialize( server, source, message )
					super( server, source )
					Kesh::ArgTest::type( "message", message, String, true )
					@message = message
				end
				
			end
		
		end
	end
end