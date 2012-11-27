requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class GenericCommand < Kesh::IRC::Command
			
				attr_reader :command
				attr_reader :tokens
				
				def initialize( command, tokens )
					super()
					Kesh::ArgTest::type( "command", command, String )
					command.strip!()
					Kesh::ArgTest::stringLength( "command", command, 1 )
					Kesh::ArgTest::type( "tokens", tokens, Array )
					@command = command
					@tokens = tokens
				end
	
				def format
					return "#{@command} #{@tokens.join( ' ' )}" if ( @tokens.length > 0 )
					return @command
				end
				
			end
		
		end
	end
end