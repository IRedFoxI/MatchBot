requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class NickEvent < Kesh::IRC::Event
			
				def NickEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length == 3 && 
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ] == "NICK" 
					)
					
					return NickEvent.new( server, tokens[ 0 ], tokens[ 2 ] )
				end
				

				attr_reader :newName
				
				def initialize( server, source, newName )
					super( server, source )
					Kesh::ArgTest::type( "newName", newName, String )
					Kesh::ArgTest::stringLength( "newName", newName, 1, server.maxNickLength )
					@newName = newName
				end
				
			end
		
		end
	end
end