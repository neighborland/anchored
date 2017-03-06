# frozen_string_literal: true

require "test_helper"
require "active_support/all"

class RailsTest < Minitest::Test
  def test_links_with_html_safe
    # active support messes with gsub
    text = "http://x.x/"
    assert_equal generate_result(text), Anchored::Linker.auto_link(text.html_safe)
  end

  def test_plain_with_html_safe
    [" ", "hello", "<a>wat</a>...", "<a href='#'>wat.</a>"].each do |text|
      assert_equal text, Anchored::Linker.auto_link(text.html_safe)
    end
  end
end
