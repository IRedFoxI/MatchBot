requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class PrivMsgCommand < Kesh::IRC::Command
			
				attr_reader :target
				attr_reader :message
				
				def initialize( target, message )
					super()
					Kesh::ArgTest::type( "target", target, [ Kesh::IRC::Client, Kesh::IRC::Channel ] )
					Kesh::ArgTest::type( "message", message, String )
					message.strip!()
					Kesh::ArgTest::stringLength( "message", message, 1 )
					@target = target
					@message = message
				end
				

				def format
					"PRIVMSG #{@target.name} :#{@message}"
				end				
				
			end
		
		end
	end
end