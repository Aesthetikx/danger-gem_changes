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
      github_span = rubygems_document.at_css("span.github-btn")

      if github_span
        user = github_span.attr("data-user")
        repo = github_span.attr("data-repo")
        return "https://github.com/#{user}/#{repo}"
      end

      code = rubygems_document.at_css("a#code")&.attr("href")
      home = rubygems_document.at_css("a#home")&.attr("href")

      [code, home].compact.first
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
