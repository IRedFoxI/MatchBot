requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class PasswordCommand < Kesh::IRC::Command
			
				attr_reader :password
				
				def initialize( password )
					super()
					Kesh::ArgTest::type( "password", password, String )
					password.strip!()
					Kesh::ArgTest::stringLength( "password", password, 1 )
					@password = password
				end
	
				def format
					"PASSWORD #{@password}"
				end
				
			end
		
		end
	end
end