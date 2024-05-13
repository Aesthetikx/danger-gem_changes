# frozen_string_literal: true

module GemChanges
  Change = Struct.new(:gem, :from, :to, keyword_init: true) do
    def initialize(gem:, from:, to:)
      super(gem:, from: Version(from), to: Version(to))
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

    def major?
      change? &&
        from.segments[0] && to.segments[0] &&
        from.segments[0] != to.segments[0]
    end

    def minor?
      change? && !major? &&
        from.segments[1] && to.segments[1] &&
        from.segments[1] != to.segments[1]
    end

    def patch?
      change? && !major? && !minor? &&
        from.segments[2] && to.segments[2] &&
        from.segments[2] != to.segments[2]
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
