# frozen_string_literal: true

module GemChanges
  module Gemfile
    REMOVAL_REGEX = /^-    ([^ ]*) \((.*)\)/.freeze
    ADDITION_REGEX = /^\+    ([^ ]*) \((.*)\)/.freeze

    module_function def changes(git:)
      diff = git.diff_for_file("Gemfile.lock")

      return [] if diff.nil?

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
  end
end
