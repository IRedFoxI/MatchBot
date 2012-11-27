requireLibrary '../../IRC'

module Kesh
	module IRC
			
		class ClientMode
		
			attr_reader :client
			attr_reader :mode
			attr_accessor :status
			
			def initialize( client, mode, status )
				Kesh::ArgTest::type( "client", client, Client )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "status", status, [ TrueClass, FalseClass ] )
				@client = client
				@mode = mode
				@status = status
			end
			
			
			def toggle
				@status = !@status
			end
			
		end
			
	end
end
		