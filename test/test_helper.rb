require "minitest/autorun"
require "anchored"
require "byebug" if ENV["BYEBUG"]

class Minitest::Test
  def generate_result(link_text, href = nil)
    href ||= link_text
    %(<a href="#{href}">#{link_text}</a>)
  end
end
