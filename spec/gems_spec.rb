# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerGems do
    it "is a plugin" do
      expect(described_class.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.gems

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
            DangerGems::Change.new(
              gem: DangerGems::Gem.new(name: "rubocop-performance"),
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
            DangerGems::Change.new(
              gem: DangerGems::Gem.new(name: "rubocop-rspec"),
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
            DangerGems::Change.new(
              gem: DangerGems::Gem.new(name: "rubocop-rake"),
              from: "0.6.0",
              to: "0.6.1"
            )
          ]
        )
      end

      it "knows about downgrades" do
        downgrades = @my_plugin.downgrades

        expect(downgrades).to eq(
          [
            DangerGems::Change.new(
              gem: DangerGems::Gem.new(name: "rubocop-factory_bot"),
              from: "2.25.1",
              to: "2.25.0"
            )
          ]
        )
      end
    end
  end
end
