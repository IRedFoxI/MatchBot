requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class WildTopLevelNumeric < Kesh::IRC::Events::NumericEvent
				
					def WildTopLevelNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == ERR_WILDTOPLEVEL
						)
						return WildTopLevelNumeric.new( server, source, id, target, tokens[ 0 ] )
					end
					
				
					attr_reader :mask
					
					def initialize( server, source, id, target, mask )
						super( server, source, id, target )
						Kesh::ArgTest::type( "mask", mask, String )
						@mask = mask
					end
					
				end
				
			end		
		end
	end
end