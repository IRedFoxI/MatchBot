requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class WelcomeNumeric < Kesh::IRC::Events::NumericEvent
				
					def WelcomeNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length == 1 &&
							id == RPL_WELCOME
						)
						return WelcomeNumeric.new( server, source, id, target, tokens[ 0 ] )
					end
					
				
					attr_reader :message
					
					def initialize( server, source, id, target, message )
						super( server, source, id, target )
						Kesh::ArgTest::type( "message", message, String )
						@message = message
					end
					
				end
				
			end		
		end
	end
end