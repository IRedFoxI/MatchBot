requireLibrary '../../../../IRC'

module Kesh
	module IRC
		module Events
			module Numerics
		
				class ServerSupportsNumeric < Kesh::IRC::Events::NumericEvent
					
					def ServerSupportsNumeric.parse( server, source, id, target, tokens )
						return nil unless (
							tokens.length >= 2 &&
							id == RPL_SUPPORTS
						) 
						
						supports = Hash[]
						
						tokens[0..-2].each do |token|
							token[/^([^=]+)(=(.*))?$/]
							supports[ $1 ] = $3
						end
						
						return ServerSupportsNumeric.new( server, source, id, target, supports, tokens[ -1 ] )
					end
					
				
					attr_reader :supports
					attr_reader :message
					
					def initialize( server, source, id, target, supports, message )
						super( server, source, id, target )
						Kesh::ArgTest::type( "supports", supports, Hash )
						Kesh::ArgTest::type( "message", message, String )
						@supports = supports
						@message = message
					end
					
				end
				
			end		
		end
	end
end