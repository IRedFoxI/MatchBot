requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class WhoWasCommand < Kesh::IRC::Command
			
				attr_reader :target
				
				def initialize( target )
					super()
					Kesh::ArgTest::type( "target", target, Kesh::IRC::Client )
					@target = target
				end
				

				def format
					return "WHOWAS #{@target.name}"
				end				
				
			end
		
		end
	end
end