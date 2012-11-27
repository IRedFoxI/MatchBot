requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class UnknownCommandNumeric < Kesh::IRC::Events::NumericEvent
				
					def UnknownCommandNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 2 &&
							id == ERR_UNKNOWNCOMMAND
						)
						return UnknownCommandNumeric.new( server, source, id, target, tokens[ 0 ] )
					end
					
				
					attr_reader :command
					
					def initialize( server, source, id, target, command )
						super( server, source, id, target )
						Kesh::ArgTest::type( "command", command, String )
						@command = command
					end
					
				end
				
			end		
		end
	end
end