requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class ServerCreatedNumeric	 < Kesh::IRC::Events::NumericEvent
				
					def ServerCreatedNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 1 &&
							id == RPL_CREATED
						)
						return ServerCreatedNumeric.new( server, source, id, target, tokens[ 0 ] )
					end
					
				
					attr_reader :date
					
					def initialize( server, source, id, target, date )
						super( server, source, id, target )
						Kesh::ArgTest::type( "date", date, String )
						@date = date
					end
					
				end
				
			end		
		end
	end
end