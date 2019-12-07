require "dry-types"

module Disposable::Twin::Coercion
  module Types
    # NOTE: Use Dry.Types() instead. Beware, it exports strict types by default, for old behavior use Dry.Types(default: :nominal)
    DRY_MODULE =  Gem::Version.new(Dry::Types::VERSION) < Gem::Version.new("0.15.0") ? Dry::Types.module : Dry.Types()
    include DRY_MODULE
  end

  DRY_TYPES_VERSION = Gem::Version.new(Dry::Types::VERSION)
  DRY_TYPES_CONSTANT = DRY_TYPES_VERSION < Gem::Version.new("0.13.0") ? Types::Form : Types::Params

  module ClassMethods
    def property(name, options={}, &block)
      super(name, options, &block).tap do
        coercing_setter!(name, options[:type], options[:nilify]) if options[:type] || options[:nilify]
      end
    end

    def coercing_setter!(name, type, nilify=false)
     type = Types::Params::Nil | (type || Types::Nominal::Nil) if nilify

      mod = Module.new do
        define_method("#{name}=") do |value|
          super type.(value)
        end
      end
      include mod
    end
  end

  def self.included(includer)
    includer.extend ClassMethods
  end
end
