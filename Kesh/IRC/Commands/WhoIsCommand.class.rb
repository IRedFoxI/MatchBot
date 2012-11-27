requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class WhoIsCommand < Kesh::IRC::Command
			
				attr_reader :target
				
				def initialize( target )
					super()
					Kesh::ArgTest::type( "target", target, Kesh::IRC::Client )
					@target = target
				end
				

				def format
					return "WHOIS #{@target.name}"
				end				
				
			end
		
		end
	end
end