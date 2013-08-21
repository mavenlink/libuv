module Libuv
    class Handle < Q::DeferredPromise
        include Assertions, Resource, Listener


        def initialize(loop, pointer, error)
            @pointer = pointer

            # Initialise the promise
            super(loop, loop.defer)

            # clean up on init error (always raise here)
            if error
                ::Libuv::Ext.free(pointer)
                defer.reject(result)
                @closed = true
                raise result
            end
        end

        # Public: Increment internal ref counter for the handle on the loop. Useful for
        # extending the loop with custom watchers that need to make loop not stop
        # 
        # Returns self
        def ref
            return if @closed
            ::Libuv::Ext.ref(handle)
        end

        # Public: Decrement internal ref counter for the handle on the loop, useful to stop
        # loop even when there are outstanding open handles
        # 
        # Returns self
        def unref
            return if @closed
            ::Libuv::Ext.unref(handle)
        end

        def close
            return if @closed
            @closed = true
            Libuv::Ext.close(handle, callback(:on_close))
        end

        def active?
            ::Libuv::Ext.is_active(handle) > 0
        end

        def closing?
            ::Libuv::Ext.is_closing(handle) > 0
        end


        protected


        def loop; @loop; end
        def handle; @pointer; end
        def defer; @defer; end


        private


        # Clean up and throw an error
        def reject(reason)
            @close_error = reason
            close
        end

        def on_close(pointer)
            ::Libuv::Ext.free(pointer)
            clear_callbacks

            if @close_error
                defer.reject(@close_error)
            else
                defer.resolve(nil)
            end
        end
    end
end