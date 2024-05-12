# frozen_string_literal: true

module GemChanges
  Change = Struct.new(:gem, :from, :to, keyword_init: true) do
    def initialize(gem:, from:, to:)
      super(gem: gem, from: Version(from), to: Version(to))
    end

    def change?
      to and from
    end

    def addition?
      from.nil?
    end

    def removal?
      to.nil?
    end

    def upgrade?
      change? and to > from
    end

    def downgrade?
      change? and to < from
    end

    private

    def Version(something)
      case something
      when nil then nil
      when ::Gem::Version then something
      else ::Gem::Version.new(something)
      end
    end
  end
end
