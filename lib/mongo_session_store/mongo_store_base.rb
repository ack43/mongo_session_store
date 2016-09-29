require 'action_dispatch/middleware/session/abstract_store'

module ActionDispatch
  module Session
    class MongoStoreBase < AbstractStore

      SESSION_RECORD_KEY = Rack::RACK_SESSION
      begin
        ENV_SESSION_OPTIONS_KEY = Rack::RACK_SESSION_OPTIONS
      rescue NameError
        # Rack 1.2.x has access to the ENV_SESSION_OPTIONS_KEY
      end

      def self.session_class
        self::Session
      end

      private
        def session_class
          self.class.session_class
        end

        def generate_sid
          # 20 random bytes in url-safe base64
          SecureRandom.base64(20).gsub('=','').gsub('+','-').gsub('/','_')
        end

        def get_session(env, sid)
          sid, record = find_or_initialize_session(sid)
          env[SESSION_RECORD_KEY] = record
          [sid, unpack(record.data)]
        end

        def find_session(env, sid)
          get_session(env, sid)
        end

        def set_session(env, sid, session_data, options = {})
          id, record = get_session_record(env, sid)
          record.data = pack(session_data)
          # Rack spec dictates that set_session should return true or false
          # depending on whether or not the session was saved or not.
          # However, ActionPack seems to want a session id instead.
          record.save ? id : false
        end

        def write_session(env, sid, session_data, options = {})
          set_session(env, sid, session_data, options)
        end


        def find_or_initialize_session(sid)
          session = (sid && session_class.where(:_id => sid).first) || session_class.new(:_id => generate_sid)
          [session._id, session]
        end

        def get_session_record(env, sid)
          if env.env[ENV_SESSION_OPTIONS_KEY][:id].nil? || !env[SESSION_RECORD_KEY]
            sid, env[SESSION_RECORD_KEY] = find_or_initialize_session(sid)
          end

          [sid, env[SESSION_RECORD_KEY]]
        end

        def delete_session(env, sid, options)
          destroy_session(env, sid, options)
        end

        def destroy_session(env, sid, options)
          unless options[:renew]
            destroy(env)
            generate_sid if !options[:drop] or options[:renew]
          else
            sid
          end
        end

        def destroy(env)
          if sid = current_session_id(env)
            _, record = get_session_record(env, sid)
            record.destroy
            env[SESSION_RECORD_KEY] = nil
          end
        end

        def pack(data)
          Marshal.dump(data)
        end

        def unpack(packed)
          return nil unless packed
          data = packed.respond_to?(:data) ? packed.data : packed.to_s
          Marshal.load(StringIO.new(data))
        end

    end
  end
end
