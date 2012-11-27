requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class InfoNumeric < Kesh::IRC::Events::NumericEvent
				
					def InfoNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 1 &&
							id == RPL_INFO
						)
						return InfoNumeric.new( server, source, id, target, tokens[ 0 ] )
					end
					
				
					attr_reader :string
					
					def initialize( server, source, id, target, string )
						super( server, source, id, target )
						Kesh::ArgTest::type( "string", string, String )
						@string = string
					end
					
				end
				
			end		
		end
	end
end