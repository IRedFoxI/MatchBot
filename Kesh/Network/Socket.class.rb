require 'socket'
requireLibrary '../../IO'
requireLibrary '../../Network'

module Kesh
	module Network
	
		# A wrapper for the socket class, that implements the Stream interface.
		class Socket < Kesh::IO::Stream
		
			# IP/Hostname that the Socket connects to.
			attr_reader :host
			
			# Port on the host that the Socket connets to.
			attr_reader :port
			
			# Address the socket binds to
			attr_reader :bind
			
			# Status of the Socket.
			#
			# * :socket_status_unconnected
			# * :socket_status_connected
			# * :socket_status_disconnected
			# * :socket_status_error			
			attr_reader :status
			
			# Socket error type.
			#
			# * :socket_error_none
			# * :socket_error_open
			# * :socket_error_read
			# * :socket_error_write
			# * :socket_error_close
			attr_reader :error

			# Exception thrown by the Socket.
			attr_reader :exception
			
			# Initialize the Socket.
			def initialize( host, port, bind )
				Kesh::ArgTest::type( "host", host, String )
				Kesh::ArgTest::type( "port", port, Fixnum )
				Kesh::ArgTest::intRange( "port", port, 1, 65535 )
				Kesh::ArgTest::type( "bind", bind, String, true )
				Kesh::ArgTest::stringLength( "bind", bind, 7, 15 ) if ( bind != nil )
				@host = host
				@port = port
				@bind = bind
				@socket = nil
				@status = :socket_status_unconnected
				@error = :socket_error_none
				@exception = nil
			end
			
			
			# Connect the Socket.
			def connect()
				raise RuntimeError.new( "Socket connection already attempted." ) unless ( @status == :socket_status_unconnected )				
				
				begin
					@socket = TCPSocket.new( @host, @port, @bind )
					@status = :socket_status_connected
					return true
				
				rescue SocketError => ex
					@exception = ex
					@error = :socket_error_open
					@status = :socket_status_error
					return false
				
				end
			end
			
			
			# Disconnect the Socket.
			def disconnect()
				raise RuntimeError.new( "Socket not yet connected." ) if ( @status == :socket_status_unconnected )
				raise RuntimeError.new( "Socket already shutdown." ) if ( @status == :socket_status_disconnected )
				raise RuntimeError.new( "Socket errored." ) if ( @status == :socket_status_error )

				begin
					@socket.shutdown
					@socket = nil
					@status = :socket_status_disconnected
					return true
					
				rescue Exception => ex
					@socket = nil
					@exception = ex
					@error = :socket_error_close
					@status = :socket_status_error
					return false
					
				end
			end
			
			
			# Read the given number of chars from the Socket.
			def read( maxLength = 1, block = true )
				raise RuntimeError.new( "Socket not yet connected." ) if ( @status == :socket_status_unconnected )
				raise RuntimeError.new( "Socket shutdown." ) if ( @status == :socket_status_disconnected )
				raise RuntimeError.new( "Socket errored." ) if ( @status == :socket_status_error )
				
				begin
					begin
						return @socket.recv( maxLength ) if ( block )
						return @socket.recv_nonblock( maxLength ) if ( !block )
					rescue Errno::EWOULDBLOCK => ex
						return nil
					end
					
				rescue SocketError => ex
					disconnect()
					@socket = nil
					@exception = ex
					@error = :socket_error_read
					@status = :socket_status_error
					return nil

				end
			end
			
			
			# Read, but not remove, the given number of bytes from the Socket.
			def peak( maxLength = 1 )
				raise RuntimeError.new( "Socket not yet connected." ) if ( @status == :socket_status_unconnected )
				raise RuntimeError.new( "Socket shutdown." ) if ( @status == :socket_status_disconnected )
				raise RuntimeError.new( "Socket errored." ) if ( @status == :socket_status_error )
				
				begin
					return @socket.recv( maxLength, Socket::MSG_PEEK )
					
				rescue SocketError => ex
					disconnect()
					@socket = nil
					@exception = ex
					@error = :socket_error_read
					@status = :socket_status_error
					return nil
					
				end
			end
			
			
			# Write the given string to the Socket.
			def write( string )
				Kesh::ArgTest::type( "string", string, String )
				Kesh::ArgTest::stringLength( "string", string, 1 )
				raise RuntimeError.new( "Socket not yet connected." ) if ( @status == :socket_status_unconnected )
				raise RuntimeError.new( "Socket shutdown." ) if ( @status == :socket_status_disconnected )
				raise RuntimeError.new( "Socket errored." ) if ( @status == :socket_status_error )
				
				begin
					@socket.send( string, 0 )
					
				rescue SocketError => ex
					disconnect()
					@socket = nil
					@exception = ex
					@error = :socket_error_read
					@status = :socket_status_error
					return nil
					
				end
			end

		end		
	end
end
