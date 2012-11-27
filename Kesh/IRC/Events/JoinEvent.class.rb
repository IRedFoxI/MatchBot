requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class JoinEvent < Kesh::IRC::Event
			
				def JoinEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length == 3 && 
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ] == "JOIN" 
					)
					
					return JoinEvent.new( server, tokens[ 0 ], server.getChannelByName( tokens[ 2 ] ) )
				end
				
			
				attr_reader :channel
				
				def initialize( server, source, channel )
					super( server, source )
					Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
					@channel = channel
				end
				
			end
		
		end
	end
end