requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class NoTopLevelNumeric < Kesh::IRC::Events::NumericEvent
				
					def NoTopLevelNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == ERR_NOTOPLEVEL
						)
						return NoTopLevelNumeric.new( server, source, id, target, tokens[ 0 ] )
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