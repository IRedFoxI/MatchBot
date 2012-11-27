requireLibrary '../../../IRC'
requireClass 'ModeEvent'

module Kesh
	module IRC
		module Events
		
			class ChannelModeEvent < ModeEvent
			
				def initialize( server, source, target, modes )
					super( server, source, target, modes )
					Kesh::ArgTest::type( "target", target, Kesh::IRC::Channel )
				end
				
			
				def ChannelModeEvent.getChannelModeArrayFromString( channel, modes, parameters )
					Kesh::ArgTest::type( "channel", channel, Channel )
					Kesh::ArgTest::type( "modes", modes, String )
					Kesh::ArgTest::stringLength( "modes", modes, 2 )
					Kesh::ArgTest::type( "parameters", parameters, Array )
					
					curParam = 0
					channelModes = []
					status = false
					
					modes.each_char do |char|
						if ( char == "+" )
							status = true
							
						elsif ( char == "-" )
							status = false
							
						else
							mode = channel.server.getChannelMode( char )
							parameter = nil
							
							# Skip this mode if we don't know what it is
							if ( mode != nil )
							
								# Flag modes
								if ( mode.type == :mode_type_flag )
									i = channelModes.index { |cm| cm.mode == mode }
									channelMode = nil
									
									if ( i == nil )
										channelMode = ChannelMode.new( channel, mode, status )
										channelModes << channelMode
										
									else
										channelModes[ i ].status = status
										
									end
								
								# Parameter modes
								elsif ( mode.type == :mode_type_parameter )
									if ( status )
										parameter = parameters[ curParam ]
										curParam += 1										
									elsif ( mode.char == 'k' )
										curParam += 1
									end

									i = channelModes.index { |cm| cm.mode == mode }
									channelMode = nil
									
									if ( i == nil )
										channelMode = ChannelMode.new( channel, mode, status, parameter )
										channelModes << channelMode
										
									else
										channelModes[ i ].status = status
										channelModes[ i ].parameter = parameter										
										
									end
									
								# List modes
								else
									# Get list parameter
									parameter = parameters[ curParam ]
									curParam += 1
									
									parameter = channel.server.getClientByName( parameter ) if ( mode.type == :mode_type_clientlist )
									
									# Get additive list
									iAdd = channelModes.index { |cm| cm.mode == mode && cm.status == true }
									channelModeAdd = nil

									if ( iAdd == nil )
										channelModeAdd = ChannelModeListDelta.new( channel, mode, true )
										channelModes << channelModeAdd
									else
										channelModeAdd = channelModes[ iAdd ]
									end

									# Get subtractive list
									iRem = channelModes.index { |cm| cm.mode == mode && cm.status == false }
									channelModeRem = nil
									
									if ( iRem == nil )
										channelModeRem = ChannelModeListDelta.new( channel, mode, false )
										channelModes << channelModeRem
									else
										channelModeRem = channelModes[ iRem ]
									end
									
									# Add to lists!
									if ( status )
										if ( channelModeRem.include?( parameter ) )
											channelModeRem.remove( parameter )
											
										else
											channelModeAdd.add( parameter )
										end
									
									# Remove from lists
									else
										if ( channelModeAdd.include?( parameter ) )
											channelModeAdd.remove( parameter )
											
										else
											channelModeRem.add( parameter )
										end
									end
								end
							end						
						end
					end
					
					return channelModes
				end						
				
			end
		
		end
	end
end