# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerGemChanges do
    it "is a plugin" do
      expect(described_class.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.gem_changes

        modified_gemfile_lock = Git::Diff::DiffFile.new(
          "base",
          path: "Gemfile.lock",
          patch: File.read("spec/fixtures/Gemfile.lock.patch")
        )

        allow(@dangerfile.git).to \
          receive(:diff_for_file)
          .with("Gemfile.lock")
          .and_return(modified_gemfile_lock)
      end

      it "knows about changes" do
        changes = @my_plugin.changes

        expect(changes.count).to eq(4)
      end

      it "knows about additions" do
        additions = @my_plugin.additions

        expect(additions).to eq(
          [
            GemChanges::Change.new(
              gem: GemChanges::Gem.new(name: "rubocop-performance"),
              from: nil,
              to: "1.21.0"
            )
          ]
        )
      end

      it "knows about removals" do
        removals = @my_plugin.removals

        expect(removals).to eq(
          [
            GemChanges::Change.new(
              gem: GemChanges::Gem.new(name: "rubocop-rspec"),
              from: "2.29.2",
              to: nil
            )
          ]
        )
      end

      it "knows about upgrades" do
        upgrades = @my_plugin.upgrades

        expect(upgrades).to eq(
          [
            GemChanges::Change.new(
              gem: GemChanges::Gem.new(name: "rubocop-rake"),
              from: "0.5.0",
              to: "0.6.0"
            )
          ]
        )
      end

      it "knows about downgrades" do
        downgrades = @my_plugin.downgrades

        expect(downgrades).to eq(
          [
            GemChanges::Change.new(
              gem: GemChanges::Gem.new(name: "rubocop-factory_bot"),
              from: "2.25.1",
              to: "2.25.0"
            )
          ]
        )
      end

      it "can generate a markdown table" do
        @my_plugin.summarize_changes

        markdown = @dangerfile.status_report[:markdowns].last.message

        expect(markdown).to eq(<<~MARKDOWN)
          ### Gemfile.lock Changes
          | Gem | Source | Changelog | Change | Level |
          | --- | ------ | --------- | ------ | ----- |
          | [rubocop-factory_bot](https://rubygems.org/gems/rubocop-factory_bot) | [Source](https://github.com/rubocop/rubocop-factory_bot) | [Changelog](https://github.com/rubocop/rubocop-factory_bot/blob/master/CHANGELOG.md) | [v2.25.0 <- v2.25.1](https://github.com/rubocop/rubocop-factory_bot/compare/v2.25.0...v2.25.1) | Patch |
          | [rubocop-performance](https://rubygems.org/gems/rubocop-performance) | [Source](https://github.com/rubocop/rubocop-performance) | [Changelog](https://github.com/rubocop/rubocop-performance/blob/master/CHANGELOG.md) | Added at 1.21.0 |  |
          | [rubocop-rake](https://rubygems.org/gems/rubocop-rake) | [Source](https://github.com/rubocop/rubocop-rake) | [Changelog](https://github.com/rubocop/rubocop-rake/blob/master/CHANGELOG.md) | [v0.5.0 -> v0.6.0](https://github.com/rubocop/rubocop-rake/compare/v0.5.0...v0.6.0) | Minor |
          | [rubocop-rspec](https://rubygems.org/gems/rubocop-rspec) | [Source](https://github.com/rubocop/rubocop-rspec) | [Changelog](https://github.com/rubocop/rubocop-rspec/blob/master/CHANGELOG.md) | Removed at 2.29.2 |  |
        MARKDOWN
      end
    end
  end
end
