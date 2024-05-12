# frozen_string_literal: true

require "nokogiri"
require "open-uri"

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
    REMOVAL_REGEX = /^-    ([^ ]*) \((.*)\)/.freeze
    ADDITION_REGEX = /^\+    ([^ ]*) \((.*)\)/.freeze

    Gem = Struct.new(:name, keyword_init: true) do
      def rubygems_uri
        "https://rubygems.org/gems/#{name}"
      end

      def changelog_uri
        rubygems_document.css("a#changelog").first["href"]
      rescue StandardError
        nil
      end

      def source_code_uri
        code = rubygems_document.at_css("a#code")
        home = rubygems_document.at_css("a#home")

        code&.[]("href") || home&.[]("href")
      rescue StandardError
        nil
      end

      private

      def rubygems_document
        @rubygems_document ||= Nokogiri::HTML(rubygems_html)
      end

      def rubygems_html
        OpenURI.open_uri(rubygems_uri).read
      end
    end

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

    class ChangeTableEntry
      attr_reader :gem, :change

      def initialize(change:)
        @change = change
        @gem = change.gem
      end

      def rubygems_link
        "[#{gem.name}](#{gem.rubygems_uri})"
      end

      def source_link
        "[Source](#{gem.source_code_uri})"
      end

      def changelog_link
        "[Changelog](#{gem.changelog_uri})"
      end

      def change_link
        text = change_text
        link = compare_uri

        if link
          "[#{text}](#{link})"
        else
          text
        end
      end

      private

      def change_text
        if change.addition?
          "Added at #{change.to}"
        elsif change.removal?
          "Removed at #{change.from}"
        elsif change.upgrade?
          "v#{change.from} -> v#{change.to}"
        elsif change.downgrade?
          "v#{change.to} <- v#{change.from}"
        else
          fail "Unknown change type"
        end
      end

      def compare_uri
        return nil unless change.change?

        from, to = [change.from, change.to].sort

        "#{gem.source_code_uri}/compare/v#{from}...v#{to}"
      end
    end

    def summarize_changes
      message = "### Gemfile.lock Changes\n"

      message += "| Gem | Source | Changelog | Change |\n"
      message += "| --- | ------ | --------- | ------ |\n"

      changes.each do |change|
        message += "| "

        entry = ChangeTableEntry.new(change: change)

        message += [
          entry.rubygems_link,
          entry.source_link,
          entry.changelog_link,
          entry.change_link
        ].join(" | ")

        message += " |\n"
      end

      markdown message
    end

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
  end
end
