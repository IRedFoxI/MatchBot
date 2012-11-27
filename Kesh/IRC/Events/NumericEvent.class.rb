requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class NumericEvent < Kesh::IRC::Event
			
				NumericClasses = []
			
				def NumericEvent.parse( server, tokens )
					Kesh::ArgTest::type( "server", server, Server )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					
					return nil unless ( 
						tokens.length >= 4 && 
						tokens[ 0 ].is_a?( Kesh::IRC::Client ) && 
						tokens[ 1 ][/^\d+$/] != nil
					)
					
					source = tokens[ 0 ]
					id = Integer( tokens[ 1 ] )
					target = server.getClientByName( tokens[ 2 ] )
					
					tokens.shift( 3 )
					
					$IRCModule.getVar( "Numerics" ).each do |c|
						nc = c.clazz
						next if ( nc == Numerics::GenericNumeric )
						next if ( nc.method( :parse ) == nil )
						next unless ( nc.to_s == nc.method(:parse).owner.to_s[ 8..-2 ] )
						numeric = nc.parse( server, source, id, target, tokens )
						return numeric unless ( numeric == nil )
					end
				
					return Numerics::GenericNumeric.new( server, source, id, target, tokens )
				end
				
			
				attr_reader :id
				attr_reader :target
				
				def initialize( server, source, id, target )
					super( server, source )
					Kesh::ArgTest::type( "id", id, Fixnum )
					Kesh::ArgTest::intRange( "id", id, 0, 999 )
					Kesh::ArgTest::type( "target", target, Client )
					@id = id
					@target = target
				end
				
				
				def isError?()
					return ( id >= 400 && id < 600 )
				end
				
				
				def isCommandResponse?()
					return ( id >= 200 && id < 400 )
				end
				
			end
		
		end
	end
end
