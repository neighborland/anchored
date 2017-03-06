# frozen_string_literal: true

require "test_helper"

class LinkerTest < Minitest::Test
  def test_version
    assert_kind_of String, Anchored::VERSION
  end

  def test_auto_link_within_tags
    link_raw    = "http://www.rubyonrails.org/images/rails.png"
    link_result = %(<img src="#{link_raw}" />)
    assert_equal link_result, auto_link(link_result)
  end

  def test_auto_link_with_brackets
    link1_raw = "http://en.wikipedia.org/wiki/Sprite_(computer_graphics)"
    link1_result = generate_result(link1_raw)
    assert_equal link1_result, auto_link(link1_raw)
    assert_equal "(link: #{link1_result})", auto_link("(link: #{link1_raw})")

    link2_raw = "http://en.wikipedia.org/wiki/Sprite_[computer_graphics]"
    link2_result = generate_result(link2_raw)
    assert_equal link2_result, auto_link(link2_raw)
    assert_equal "[link: #{link2_result}]", auto_link("[link: #{link2_raw}]")

    link3_raw = "http://en.wikipedia.org/wiki/Sprite_{computer_graphics}"
    link3_result = generate_result(link3_raw)
    assert_equal link3_result, auto_link(link3_raw)
    assert_equal "{link: #{link3_result}}", auto_link("{link: #{link3_raw}}")
  end

  def test_auto_link_with_options_hash
    assert_equal 'Welcome to my new blog at <a href="http://www.myblog.com/" class="menu" target="_blank">http://www.myblog.com/</a>. Please e-mail me at me@email.com.',
      auto_link("Welcome to my new blog at http://www.myblog.com/. Please e-mail me at me@email.com.",
        class: "menu", target: "_blank")
  end

  def test_auto_link_with_multiple_trailing_punctuations
    url = "http://youtube.com"
    url_result = generate_result(url)
    assert_equal url_result, auto_link(url)
    assert_equal "(link: #{url_result}).", auto_link("(link: #{url}).")
  end

  def test_auto_link_with_block
    url = "http://api.rubyonrails.com/Foo.html"
    assert_equal %(<p><a href="#{url}">api.rubyonrails...</a><br /></p>),
      auto_link("<p>#{url}<br /></p>") { |url| url.split("http://").last[0...15] + "..." }
  end

  def test_auto_link_with_block_with_html
    pic = "http://example.com/pic.png"
    url = "http://example.com/album?a&b=c"

    actual = auto_link("My pic: #{pic} -- #{url}") do |link|
      if link.match(/\.(jpg|gif|png)$/i)
        %(<img src="#{link}" width="160px">)
      else
        link
      end
    end

    assert_equal(%(My pic: <a href="#{pic}"><img src="#{pic}" width="160px"></a> -- #{generate_result(url)}),
      actual)
  end

  def test_auto_link_ftp
    ftp_raw = "ftp://example.com/file.txt"
    assert_equal %(Download #{generate_result(ftp_raw)}), auto_link("Download #{ftp_raw}")
  end

  def test_auto_link_already_linked
    linked1 = generate_result("Ruby On Rails", "http://www.rubyonrails.com")
    linked2 = %('<a href="http://www.example.com">www.example.com</a>')
    linked3 = %('<a href="http://www.example.com" rel="nofollow">www.example.com</a>')
    linked4 = %('<a href="http://www.example.com"><b>www.example.com</b></a>')
    linked5 = %('<a href="#close">close</a> <a href="http://www.example.com"><b>www.example.com</b></a>')
    assert_equal linked1, auto_link(linked1)
    assert_equal linked2, auto_link(linked2)
    assert_equal linked3, auto_link(linked3)
    assert_equal linked4, auto_link(linked4)
    assert_equal linked5, auto_link(linked5)
  end

  def test_auto_link_with_malicious_attr
    url1 = "http://api.rubyonrails.com/Foo.html"
    malicious = "\"onmousemove=\"prompt()"
    combination = "#{url1}#{malicious}"

    assert_equal %(<p><a href="#{url1}">#{url1}</a>#{malicious}</p>), auto_link("<p>#{combination}</p>")
  end

  def test_auto_link_at_eol
    url1 = "http://api.rubyonrails.com/Foo.html"
    url2 = "http://www.ruby-doc.org/core/Bar.html"

    assert_equal %(<p><a href="#{url1}">#{url1}</a><br /><a href="#{url2}">#{url2}</a><br /></p>), auto_link("<p>#{url1}<br />#{url2}<br /></p>")
  end

  def test_auto_link
    link_raw     = "http://www.rubyonrails.com"
    link_result  = generate_result(link_raw)
    link_result_with_options = %(<a href="#{link_raw}" target="_blank">#{link_raw}</a>)

    assert_equal "", auto_link(nil)
    assert_equal "", auto_link("")
    assert_equal "#{link_result} #{link_result} #{link_result}", auto_link("#{link_raw} #{link_raw} #{link_raw}")

    assert_equal %(Go to #{link_result}), auto_link("Go to #{link_raw}")
    assert_equal %(<p>Link #{link_result}</p>), auto_link("<p>Link #{link_raw}</p>")
    assert_equal %(<p>#{link_result} Link</p>), auto_link("<p>#{link_raw} Link</p>")
    assert_equal %(<p>Link #{link_result_with_options}</p>), auto_link("<p>Link #{link_raw}</p>", target: "_blank")
    assert_equal %(Go to #{link_result}.), auto_link(%(Go to #{link_raw}.))
    assert_equal %(#{link_result} #{link_result}), auto_link(%(#{link_result} #{link_raw}))

    link2_raw    = "www.rubyonrails.com"
    link2_result = generate_result(link2_raw, "http://#{link2_raw}")
    assert_equal %(Go to #{link2_result}), auto_link("Go to #{link2_raw}")
    assert_equal %(<p>Link #{link2_result}</p>), auto_link("<p>Link #{link2_raw}</p>")
    assert_equal %(<p>#{link2_result} Link</p>), auto_link("<p>#{link2_raw} Link</p>")
    assert_equal %(Go to #{link2_result}.), auto_link(%(Go to #{link2_raw}.))

    link3_raw    = "http://manuals.ruby-on-rails.com/read/chapter.need_a-period/103#page281"
    link3_result = generate_result(link3_raw)
    assert_equal %(Go to #{link3_result}), auto_link("Go to #{link3_raw}")
    assert_equal %(<p>Link #{link3_result}</p>), auto_link("<p>Link #{link3_raw}</p>")
    assert_equal %(<p>#{link3_result} Link</p>), auto_link("<p>#{link3_raw} Link</p>")
    assert_equal %(Go to #{link3_result}.), auto_link(%(Go to #{link3_raw}.))

    link4_raw    = "http://foo.example.com/controller/action?parm=value&p2=v2#anchor123"
    link4_result = generate_result(link4_raw)
    assert_equal %(<p>Link #{link4_result}</p>), auto_link("<p>Link #{link4_raw}</p>")
    assert_equal %(<p>#{link4_result} Link</p>), auto_link("<p>#{link4_raw} Link</p>")

    link5_raw    = "http://foo.example.com:3000/controller/action"
    link5_result = generate_result(link5_raw)
    assert_equal %(<p>#{link5_result} Link</p>), auto_link("<p>#{link5_raw} Link</p>")

    link6_raw    = "http://foo.example.com:3000/controller/action+pack"
    link6_result = generate_result(link6_raw)
    assert_equal %(<p>#{link6_result} Link</p>), auto_link("<p>#{link6_raw} Link</p>")

    link7_raw    = "http://foo.example.com/controller/action?parm=value&p2=v2#anchor-123"
    link7_result = generate_result(link7_raw)
    assert_equal %(<p>#{link7_result} Link</p>), auto_link("<p>#{link7_raw} Link</p>")

    link8_raw    = "http://foo.example.com:3000/controller/action.html"
    link8_result = generate_result(link8_raw)
    assert_equal %(Go to #{link8_result}), auto_link("Go to #{link8_raw}")
    assert_equal %(<p>Link #{link8_result}</p>), auto_link("<p>Link #{link8_raw}</p>")
    assert_equal %(<p>#{link8_result} Link</p>), auto_link("<p>#{link8_raw} Link</p>")
    assert_equal %(Go to #{link8_result}.), auto_link(%(Go to #{link8_raw}.))

    link9_raw    = "http://business.timesonline.co.uk/article/0,,9065-2473189,00.html"
    link9_result = generate_result(link9_raw)
    assert_equal %(Go to #{link9_result}), auto_link("Go to #{link9_raw}")
    assert_equal %(<p>Link #{link9_result}</p>), auto_link("<p>Link #{link9_raw}</p>")
    assert_equal %(<p>#{link9_result} Link</p>), auto_link("<p>#{link9_raw} Link</p>")
    assert_equal %(Go to #{link9_result}.), auto_link(%(Go to #{link9_raw}.))

    link10_raw    = "http://www.mail-archive.com/ruby-talk@ruby-lang.org/"
    link10_result = generate_result(link10_raw)
    assert_equal %(<p>#{link10_result} Link</p>), auto_link("<p>#{link10_raw} Link</p>")

    link12_raw    = "http://tools.ietf.org/html/rfc3986"
    link12_result = generate_result(link12_raw)
    assert_equal %(<p>#{link12_result} text-after-nonbreaking-space</p>), auto_link("<p>#{link12_raw} text-after-nonbreaking-space</p>")

    link13_raw = "HTtP://www.rubyonrails.com"
    assert_equal generate_result(link13_raw), auto_link(link13_raw)
  end

  def test_auto_link_parsing
    %w(
      http://www.rubyonrails.com
      http://www.rubyonrails.com:80
      http://www.rubyonrails.com/~minam
      https://www.rubyonrails.com/~minam
      http://www.rubyonrails.com/~minam/url%20with%20spaces
      http://www.rubyonrails.com/foo.cgi?something=here
      http://www.rubyonrails.com/foo.cgi?something=here&and=here
      http://www.rubyonrails.com/contact;new
      http://www.rubyonrails.com/contact;new%20with%20spaces
      http://www.rubyonrails.com/contact;new?with=query&string=params
      http://www.rubyonrails.com/~minam/contact;new?with=query&string=params
      http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_picture_%28animation%29/January_20%2C_2007
      http://www.mail-archive.com/rails@lists.rubyonrails.org/
      http://www.amazon.com/Testing-Equal-Sign-In-Path/ref=pd_bbs_sr_1?ie=UTF8&s=books&qid=1198861734&sr=8-1
      http://en.wikipedia.org/wiki/Texas_hold'em
      https://www.google.com/doku.php?id=gps:resource:scs:start
      http://connect.oraclecorp.com/search?search[q]=green+france&search[type]=Group
      http://of.openfoundry.org/projects/492/download#4th.Release.3
      http://maps.google.co.uk/maps?f=q&q=the+london+eye&ie=UTF8&ll=51.503373,-0.11939&spn=0.007052,0.012767&z=16&iwloc=A
      http://около.кола/колокола
    ).each do |url|
      assert_equal generate_result(url), auto_link(url)
    end
  end

  def test_autolink_with_trailing_equals_on_link
    url = "http://www.rubyonrails.com/foo.cgi?trailing_equals="
    assert_equal generate_result(url), auto_link(url)
  end

  def test_autolink_with_trailing_amp_on_link
    url = "http://www.rubyonrails.com/foo.cgi?trailing_ampersand=value&"
    assert_equal generate_result(url), auto_link(url)
  end

  def test_remove_target_if_local
    url = "http://example.com/yo?x"
    options = {}
    Anchored::Linker.remove_target_if_local url, "example.com", options
    assert_equal({}, options)

    options = { class: "x" }
    Anchored::Linker.remove_target_if_local url, "example.com", options
    assert_equal({ class: "x" }, options)

    options = { target: "x" }
    Anchored::Linker.remove_target_if_local url, "example.com", options
    assert_equal({}, options)

    options = { class: "x", target: "x" }
    Anchored::Linker.remove_target_if_local url, "example.com", options
    assert_equal({ class: "x" }, options)
  end

  def test_remove_target_not_local
    url = "http://example.com/yo?x"
    options = {}
    Anchored::Linker.remove_target_if_local url, "x.com", options
    assert_equal({}, options)

    options = { class: "x" }
    Anchored::Linker.remove_target_if_local url, "x.com", options
    assert_equal({ class: "x" }, options)

    options = { target: "x" }
    Anchored::Linker.remove_target_if_local url, "x.com", options
    assert_equal({ target: "x" }, options)

    options = { class: "x", target: "x" }
    Anchored::Linker.remove_target_if_local url, "x.com", options
    assert_equal({ class: "x", target: "x" }, options)
  end

  def test_autolink_with_target_and_domain
    assert_equal %(hello <a href="http://example.com/x">http://example.com/x</a>.),
      Anchored::Linker.auto_link("hello http://example.com/x.", target: "_blank", domain: "example.com")

    assert_equal %(hello <a href="http://example.com/x" target="_blank">http://example.com/x</a>.),
      Anchored::Linker.auto_link("hello http://example.com/x.", target: "_blank", domain: "ample.com")
  end

  def test_autolink_options_with_many
    text = "hello http://x.com/x. hello http://y.com/x."
    expected = %(hello <a href="http://x.com/x">http://x.com/x</a>. ) +
               %(hello <a href="http://y.com/x" target="_blank">http://y.com/x</a>.)
    assert_equal expected, Anchored::Linker.auto_link(text, target: "_blank", domain: "x.com")
  end

  private

  def auto_link(*args, &block)
    Anchored::Linker.auto_link(*args, &block)
  end
end
