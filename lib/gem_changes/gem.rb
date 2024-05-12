# frozen_string_literal: true

require "nokogiri"
require "open-uri"

module GemChanges
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
end
