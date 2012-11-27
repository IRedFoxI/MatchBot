requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class GenericEvent < Kesh::IRC::Event
			
				def GenericEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length > 2 && 
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ][/^\d+$/] == nil
					)
					
					source = tokens[ 0 ]
					type = tokens[ 1 ]
					tokens.shift( 2 )
					
					return GenericEvent.new( server, source, type, tokens )
				end
				
				attr_reader :type
				attr_reader :tokens
				
				def initialize( server, source, type, tokens )
					super( server, source )
					Kesh::ArgTest::type( "type", type, String )
					type.strip!()
					Kesh::ArgTest::stringLength( "type", type, 1 )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					@type = type
					@tokens = tokens
				end
				
			end
		
		end
	end
end