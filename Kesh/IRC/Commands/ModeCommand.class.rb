requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class ModeCommand < Kesh::IRC::Command
			
				def ModeCommand.listToString( modes )
					Kesh::ArgTest::type( "modes", modes, Array )
					
					modeString = ""
					params = []
					status = false
					
					@modes.each do |cm|
						modeString += ( cm.status ? "+" : "-" ) if ( cm.status != status || modeString == "" )
						modeString += cm.mode.char
						
						if ( cm.mode.type != :mode_type_flag )
							params << cm.parameter unless ( cm.mode.type == :mode_type_parameter && cm.status == false && cm.mode.char != 'k' )
						end

						status = cm.status
					end							

					return modeString				
				end
				
				
				attr_reader :target
				attr_reader :modeString
				
				def initialize( target, modeString = nil )
					super()
					Kesh::ArgTest::type( "target", target, [ Kesh::IRC::Client, Kesh::IRC::Channel ] )
					Kesh::ArgTest::type( "modeString", modeString, String, true )
					modeString.strip!() unless ( modeString == nil )
					@target = target
					@modeString = modeString
				end
				

				def format
					return "MODE #{@target.name} #{@modeString}" unless ( @modeString == nil || @modeString == "" )
					return "MODE #{@target.name}"
				end				
				
			end
		
		end
	end
end