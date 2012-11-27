requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class UserCommand < Kesh::IRC::Command
			
				attr_reader :ident
				attr_reader :hostName
				attr_reader :server
				attr_reader :realName
				
				def initialize( ident, hostName, serverName, realName )
					super()
					Kesh::ArgTest::type( "ident", ident, String )
					ident.strip!()
					Kesh::ArgTest::stringLength( "ident", ident, 1, 20 )
					Kesh::ArgTest::type( "hostName", hostName, String )
					hostName.strip!()
					Kesh::ArgTest::stringLength( "hostName", hostName, 3, 40 )
					Kesh::ArgTest::type( "serverName", serverName, String )
					serverName.strip!()
					Kesh::ArgTest::stringLength( "serverName", serverName, 3, 40 )
					Kesh::ArgTest::type( "realName", realName, String )
					realName.strip!()
					Kesh::ArgTest::stringLength( "realName", realName, 1, 20 )
					@ident = ident
					@hostName = hostName
					@serverName = serverName
					@realName = realName
				end
	
				def format
					"USER #{@ident} #{@hostName} #{@serverName} :#{@realName}"
				end
				
			end
			
		end
	end
end
