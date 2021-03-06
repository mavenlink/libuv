# frozen_string_literal: true

module Libuv
    class Async < Handle


        define_callback function: :on_async


        # @param reactor [::Libuv::Reactor] reactor this async callback will be associated
        def initialize(reactor, callback = nil, &blk)
            @reactor = reactor
            @callback = callback || blk

            async_ptr = ::Libuv::Ext.allocate_handle_async
            on_async = callback(:on_async, async_ptr.address)
            error = check_result(::Libuv::Ext.async_init(reactor.handle, async_ptr, on_async))

            super(async_ptr, error)
        end

        # Triggers a notify event, calling everything in the notify chain
        def call
            return if @closed
            error = check_result ::Libuv::Ext.async_send(handle)
            reject(error) if error
            self
        end

        # Used to update the callback that will be triggered when async is called
        #
        # @param callback [Proc] the callback to be called on reactor prepare
        def progress(callback = nil, &blk)
            @callback = callback || blk
            self
        end


        private


        def on_async(handle)
            ::Fiber.new {
                begin
                    @callback.call
                rescue Exception => e
                    @reactor.log e, 'performing async callback'
                end
            }.resume
        end
    end
end
