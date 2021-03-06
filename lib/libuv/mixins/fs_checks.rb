# frozen_string_literal: true

module Libuv
    module FsChecks


        module ClassMethods
            def fs_lookup(ref)
                ref.to_ptr.address
            end
        end

        def self.included(base)
            base.extend(ClassMethods)
        end


        def stat(wait: true)
            @stat_deferred = @reactor.defer

            request = ::Libuv::Ext.allocate_request_fs
            pre_check @stat_deferred, request, ::Libuv::Ext.fs_fstat(@reactor.handle, request, @fileno, callback(:on_stat, request.address))
            promise = @stat_deferred.promise

            wait ? co(promise) : promise
        end


        protected


        def respond(wait, promise)
            if wait
                co(promise)
                self
            else
                promise
            end
        end


        private


        def on_stat(req)
            if post_check(req, @stat_deferred)
                uv_stat = req[:stat]
                uv_members = uv_stat.members

                stats = {}
                uv_members.each do |key|
                    stats[key] = uv_stat[key]
                end

                cleanup(req)
                ::Fiber.new { @stat_deferred.resolve(stats) }.resume
            end
            @stat_deferred = nil
        end

        def pre_check(deferrable, request, result)
            error = check_result result
            if error
                @request_refs.delete request.address
                ::Libuv::Ext.free(request)
                deferrable.reject(error)
            end
            deferrable.promise
        end

        def cleanup(req)
            cleanup_callbacks req.to_ptr.address

            ::Libuv::Ext.fs_req_cleanup(req)
            ::Libuv::Ext.free(req)
        end

        def post_check(req, deferrable)
            error = check_result(req[:result])
            if error
                cleanup(req)

                ::Fiber.new {
                    deferrable.reject(error)
                    if @coroutine
                        @coroutine.resolve(deferrable.promise)
                        @coroutine = nil
                    end
                }.resume
                false
            else
                true
            end
        end
    end
end
