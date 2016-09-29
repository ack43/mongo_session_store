require 'mongoid'
require 'mongo_session_store/mongo_store_base'

module ActionDispatch
  module Session
    class MongoidStore < MongoStoreBase
      BINARY_CLASS = defined?(Moped::BSON::Binary) ? Moped::BSON::Binary : BSON::Binary

      class Session
        include Mongoid::Document
        include Mongoid::Timestamps

        # field :enabled, type: Mongoid::Boolean, default: true
        # scope :enabled,   -> { where(enabled: true) }
        # scope :disabled,  -> { where(enabled: false) }
        # default_scope -> {
        #   enabled
        # }

        store_in :collection => MongoSessionStore.collection_name

        if Mongoid::Fields::Validators::Macro::OPTIONS.include? :overwrite
          field :_id, :type => String, :overwrite => true
        else
          field :_id, :type => String
        end
        field :data, :type => BINARY_CLASS, :default => -> { marshaled_binary({}) }
        # attr_accessible :_id, :data, :enabled if respond_to?(:attr_accessible)
        attr_accessible :_id, :data if respond_to?(:attr_accessible)

        def marshaled_binary(data)
          self.class.marshaled_binary(data)
        end

        def self.marshaled_binary(data)
          if BINARY_CLASS.to_s == 'BSON::Binary'
            BSON::Binary.new(Marshal.dump(data), :generic)
          else
            Moped::BSON::Binary.new(:generic, Marshal.dump(data))
          end
        end

        # def destroy(_destroy = false)
        #   if _destroy
        #     super
        #   else
        #     self.enabled = false
        #     self.save
        #   end
        # end
        #
        # def destroy!
        #   destroy(true)
        # end
      end


      private
      def pack(data)
        session_class.marshaled_binary(data)
      end

      def unpack(packed)
        return nil unless packed
        Marshal.load(extract_data(packed))
      end

      def extract_data(packed)
        if packed.class.to_s == 'BSON::Binary'
          packed.data
        else
          packed.to_s
        end
      end
    end
  end
end

MongoidStore = ActionDispatch::Session::MongoidStore
