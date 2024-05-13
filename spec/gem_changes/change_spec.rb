# frozen_string_literal: true

require "spec_helper"

describe GemChanges::Change do
  let(:gem) { GemChanges::Gem.new(name: "bummr") }

  describe "patch levels" do
    let(:major) { described_class.new(gem:, from: "1.1.1", to: "2.1.1") }

    let(:minor) { described_class.new(gem:, from: "1.1.1", to: "1.2.1") }

    let(:patch) { described_class.new(gem:, from: "1.1.1", to: "1.1.2") }

    describe "#major?" do
      it "is true for major changes" do
        expect(major).to be_major
      end

      it "is false for minor changes" do
        expect(minor).not_to be_major
      end

      it "is false for patch changes" do
        expect(patch).not_to be_major
      end
    end

    describe "#minor?" do
      it "is false for major changes" do
        expect(major).not_to be_minor
      end

      it "is true for minor changes" do
        expect(minor).to be_minor
      end

      it "is false for patch changes" do
        expect(patch).not_to be_minor
      end
    end

    describe "#patch?" do
      it "is false for major changes" do
        expect(major).not_to be_patch
      end

      it "is false for minor changes" do
        expect(minor).not_to be_patch
      end

      it "is true for patch changes" do
        expect(patch).to be_patch
      end
    end
  end
end
