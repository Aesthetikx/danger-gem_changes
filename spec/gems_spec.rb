# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerGems do
    it "is a plugin" do
      expect(described_class.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
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

      # Some examples for writing tests
      # You should replace these with your own.

      it "Warns on a monday" do
        monday_date = Date.parse("2016-07-11")
        allow(Date).to receive(:today).and_return monday_date

        @my_plugin.warn_on_mondays

        expect(@dangerfile.status_report[:warnings]).to eq(["Trying to merge code on a Monday"])
      end

      it "Does nothing on a tuesday" do
        monday_date = Date.parse("2016-07-12")
        allow(Date).to receive(:today).and_return monday_date

        @my_plugin.warn_on_mondays

        expect(@dangerfile.status_report[:warnings]).to eq([])
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
