requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class UnknownModeNumeric < Kesh::IRC::Events::NumericEvent
				
					def UnknownModeNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == ERR_UNKNOWNMODE
						)
						return UnknownModeNumeric.new( server, source, id, target, tokens[ 0 ] )
					end
					
				
					attr_reader :char
					
					def initialize( server, source, id, target, char )
						super( server, source, id, target )
						Kesh::ArgTest::type( "char", char, String )
						@char = char
					end
					
				end
				
			end		
		end
	end
end