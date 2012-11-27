requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Events
		
			class ActionMsgEvent < Kesh::IRC::Event

				attr_reader :target
				attr_reader :message
				
				def initialize( server, source, target, message )
					super( server, source )
					Kesh::ArgTest::type( "target", target, [ Kesh::IRC::Client, Kesh::IRC::Channel ] )
					Kesh::ArgTest::type( "message", message, String )
					@target = target
					@message = message
				end	
				
			end
		
		end
	end
end