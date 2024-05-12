# frozen_string_literal: true

module GemChanges
  class SummaryTable
    attr_reader :changes

    def initialize(changes:)
      @changes = changes
    end

    def markdown
      string = ""

      string += "| Gem | Source | Changelog | Change |\n"
      string += "| --- | ------ | --------- | ------ |\n"

      rows = changes.map { |change| Row.new(change: change) }

      string += rows.map(&:markdown).join

      string
    end

    class Row
      attr_reader :gem, :change

      def initialize(change:)
        @change = change
        @gem = change.gem
      end

      def markdown
        string = "| "

        string += [
          rubygems_link,
          source_link,
          changelog_link,
          change_link
        ].join(" | ")

        string += " |\n"

        string
      end

      def rubygems_link
        "[#{gem.name}](#{gem.rubygems_uri})"
      end

      def source_link
        if gem.source_code_uri
          "[Source](#{gem.source_code_uri})"
        else
          "???"
        end
      end

      def changelog_link
        if gem.changelog_uri
          "[Changelog](#{gem.changelog_uri})"
        else
          "???"
        end
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
