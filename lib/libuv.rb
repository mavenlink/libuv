require 'forwardable'
require 'ffi'

module Libuv
    require 'libuv/ext/ext'
    require 'libuv/q'

    autoload :Resource, 'libuv/resource'
    autoload :Listener, 'libuv/listener'
    autoload :Net, 'libuv/net'
    autoload :Handle, 'libuv/handle'
    autoload :Stream, 'libuv/stream'
    autoload :Loop, 'libuv/loop'
    autoload :Error, 'libuv/error'
    autoload :Timer, 'libuv/timer'
    autoload :TCP, 'libuv/tcp'
    autoload :UDP, 'libuv/udp'
    autoload :TTY, 'libuv/tty'
    autoload :Pipe, 'libuv/pipe'
    autoload :Prepare, 'libuv/prepare'
    autoload :Check, 'libuv/check'
    autoload :Idle, 'libuv/idle'
    autoload :Async, 'libuv/async'
    autoload :SimpleAsync, 'libuv/simple_async'
    autoload :Work, 'libuv/work'
    autoload :Filesystem, 'libuv/filesystem'
    autoload :File, 'libuv/file'
    autoload :FSEvent, 'libuv/fs_event'
    autoload :Assertions, 'libuv/assertions'
end
