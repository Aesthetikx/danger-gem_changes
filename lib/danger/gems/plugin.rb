# frozen_string_literal: true

module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  Aesthetikx/danger-gems
  # @tags monday, weekends, time, rattata
  #
  class DangerGems < Plugin
    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<String>]
    attr_accessor :my_attribute

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
    def warn_on_mondays
      warn "Trying to merge code on a Monday" if Date.today.wday == 1
    end

    REMOVAL_REGEX = /^-    ([^ ]*) \((.*)\)/.freeze
    ADDITION_REGEX = /^\+    ([^ ]*) \((.*)\)/.freeze

    def changes
      diff = git.diff_for_file("Gemfile.lock")

      added = {}

      diff.patch.scan(ADDITION_REGEX).each do |match|
        added[match[0]] = match[1]
      end

      removed = {}

      diff.patch.scan(REMOVAL_REGEX).each do |match|
        removed[match[0]] = match[1]
      end

      all_gems = added.keys | removed.keys

      all_gems.map do |gem_name|
        gem = Gem.new(name: gem_name)

        Change.new(gem: gem, from: removed[gem_name], to: added[gem_name])
      end
    end

    def additions
      changes.select(&:addition?)
    end

    def removals
      changes.select(&:removal?)
    end

    def upgrades
      changes.select(&:upgrade?)
    end

    def downgrades
      changes.select(&:downgrade?)
    end

    Gem = Struct.new(:name, keyword_init: true)

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
end
