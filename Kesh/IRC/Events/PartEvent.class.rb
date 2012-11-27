requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class PartEvent < Kesh::IRC::Event
			
				def PartEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )

					return nil unless ( 
						( tokens.length == 3 || tokens.length == 4 ) &&
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ] == "PART" 
					)

					return PartEvent.new( server, tokens[ 0 ], server.getChannelByName( tokens[ 2 ] ), tokens[ 3 ] )
				end
				
			
				attr_reader :channel
				attr_reader :message
				
				def initialize( server, source, channel, message )
					super( server, source )
					Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
					Kesh::ArgTest::type( "message", message, String, true )
					@channel = channel
					@message = message
				end
				
			end
		
		end
	end
end