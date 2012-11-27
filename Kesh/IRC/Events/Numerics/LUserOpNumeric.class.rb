requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class LUserOpNumeric < Kesh::IRC::Events::NumericEvent
				
					def LUserOpNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == RPL_LUSEROP
						)
						
						return LUserOpNumeric.new( server, source, id, target, Integer( tokens[ 0 ] ) )
					end
					
				
					attr_reader :operators
				
					def initialize( server, source, id, target, operators )
						super( server, source, id, target )
						Kesh::ArgTest::type( "operators", operators, Fixnum )
						@operators = operators
					end
					
				end
				
			end		
		end
	end
end