# frozen_string_literal: true

module Gems
  class SummaryTable
    attr_reader :changes

    def initialize(changes:)
      @changes = changes
    end

    def markdown
      string = "### Gemfile.lock Changes\n"

      string += "| Gem | Source | Changelog | Change |\n"
      string += "| --- | ------ | --------- | ------ |\n"

      changes.each do |change|
        string += "| "

        entry = Entry.new(change: change)

        string += [
          entry.rubygems_link,
          entry.source_link,
          entry.changelog_link,
          entry.change_link
        ].join(" | ")

        string += " |\n"
      end

      string
    end

    class Entry
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
  end
end
