require 'socket'

module Libuv
    module Net


        IP_ARGUMENT_ERROR = "ip must be a String".freeze                # Arguments specifying an IP address
        PORT_ARGUMENT_ERROR = "port must be an Integer".freeze          # Arguments specifying an IP port


        private


        def get_sockaddr_and_len
            sockaddr = FFI::MemoryPointer.new(UV::Sockaddr)
            len = FFI::MemoryPointer.new(:int)
            len.put_int(0, UV::Sockaddr.size)
            [sockaddr, len]
        end

        def get_ip_and_port(sockaddr, len=nil)
            if sockaddr[:sa_family] == Socket::Constants::AF_INET6
                len ||= Socket::Constants::INET6_ADDRSTRLEN
                sockaddr_in6 = UV::SockaddrIn6.new(sockaddr.pointer)
                ip_ptr = FFI::MemoryPointer.new(:char, len)
                ::Libuv::Ext.ip6_name(sockaddr_in6, ip_ptr, len)
                port = ::Libuv::Ext.ntohs(sockaddr_in6[:sin6_port])
            else
                len ||= Socket::Constants::INET_ADDRSTRLEN
                sockaddr_in = UV::SockaddrIn.new(sockaddr.pointer)
                ip_ptr = FFI::MemoryPointer.new(:char, len)
                ::Libuv::Ext.ip4_name(sockaddr_in, ip_ptr, len)
                port = ::Libuv::Ext.ntohs(sockaddr_in[:sin_port])
            end
            [ip_ptr.read_string, port]
        end
    end
end