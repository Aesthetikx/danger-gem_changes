# frozen_string_literal: true

require "gem_changes"

module Danger
  # A Danger plugin that can help code review for PRs that have changes to Gemfile.lock.
  #
  # @example Print a markdown table summarizing all gem dependency changes
  #
  #          gem_changes.summarize_changes
  #
  # @see Aesthetikx/danger-gem_changes
  class DangerGemChanges < Plugin
    # Print a summary of the changes to the Gemfile.lock.
    # @param changes [Array<GemChanges::Change>] An optional list of changes to summarize, defaulting to all changes.
    # @param title [String] An optional title for the header.
    # @return [void]
    def summarize_changes(changes: self.changes, title: "Gemfile.lock Changes")
      return if changes.empty?

      string = "### #{title}\n"

      string += GemChanges::SummaryTable.new(changes:).markdown

      markdown string
    end

    # All dependencies that have changed.
    # @return [Array<GemChanges::Change>]
    def changes
      GemChanges::Gemfile.changes(git:)
    end

    # New dependencies that have been added.
    # @return [Array<GemChanges::Change>]
    def additions
      changes.select(&:addition?)
    end

    # Dependencies that have been removed.
    # @return [Array<GemChanges::Change>]
    def removals
      changes.select(&:removal?)
    end

    # Dependencies that were upgraded.
    # @return [Array<GemChanges::Change>]
    def upgrades
      changes.select(&:upgrade?)
    end

    # Dependencies that were downgraded.
    # @return [Array<GemChanges::Change>]
    def downgrades
      changes.select(&:downgrade?)
    end
  end
end
