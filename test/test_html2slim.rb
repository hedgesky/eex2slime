require 'rubygems'
require 'tmpdir'
require 'minitest/autorun'
require_relative '../lib/eex2slime'

MiniTest.autorun

class TestEEx2Slime < MiniTest::Test
  def setup
    create_html_file
  end

  def teardown
    cleanup_tmp_files
  end

  def test_id_and_class_rules
    IO.popen("bin/html2slime test/fixtures/id_and_class_rules.html -", "r") do |f|
      assert_equal File.read("test/fixtures/id_and_class_rules.slime"), f.read
    end
  end

  def test_convert_slim_lang_html
    IO.popen("bin/html2slime test/fixtures/slim-lang.html -", "r") do |f|
      assert_equal File.read("test/fixtures/slim-lang.slime"), f.read
    end
  end

  def test_convert_erb
    IO.popen("bin/eex2slime test/fixtures/eex-example.html.eex -", "r") do |f|
      assert_equal File.read("test/fixtures/eex-example.html.slime"), f.read
    end
  end

  def test_convert_multiline_function
    IO.popen("bin/eex2slime test/fixtures/multiline_function.eex -", "r") do |f|
      assert_equal File.read("test/fixtures/multiline_function.slime"), f.read
    end
  end

  # It would be cool to use better indentation for case clauses,
  # but I don't know how to implement it with current gsub'y approach.
  def test_convert_control_flow_blocks
    IO.popen("bin/eex2slime test/fixtures/control_flow.eex -", "r") do |f|
      assert_equal File.read("test/fixtures/control_flow.slime"), f.read
    end
  end

  def test_convert_file_to_stdout
    File.open(html_file, "w") do |f|
      f.puts "<p><h1>Hello</h1></p>"
    end

    IO.popen("bin/html2slime #{html_file} -", "r") do |f|
      assert_equal "p\n  h1\n    | Hello\n", f.read
    end
  end

  def test_convert_stdin_to_stdout
    File.open(html_file, "w") do |f|
      f.puts "<p><h1>Hello</h1></p>"
    end

    IO.popen("cat #{html_file} | bin/html2slime", "r") do |f|
      assert_equal "p\n  h1\n    | Hello\n", f.read
    end
  end

  def test_via_regular_ruby_call
    actual = EEx2Slime.convert!("test/fixtures/control_flow.eex", :eex)
    assert_equal File.read("test/fixtures/control_flow.slime").strip, actual
  end

  def test_data_attributes
    html = '<a href="test" data-param1="var" data-param2="(1 + 1)" data-param3="string"></a>'
    slim = 'a[href="test" data-param1="var" data-param2="(1 + 1)" data-param3="string"]'
    assert_html_to_slim html, slim
  end

  def test_escaped_text
    text = "this is js code sample.&nbsp; &raquo; &lt;script&gt;alert(0)&lt;/script&gt;"
    assert_html_to_slim text, "| #{text}"
    assert_erb_to_slim text, "| #{text}"
  end

  def test_with_leading_dash
    assert_erb_to_slim '<%- test() %>', "- test()"
  end

  private

  def assert_html_to_slim(given_html, expected_slim)
    actual_slim = EEx2Slime::HTMLConverter.new(given_html).to_s
    assert_equal expected_slim, actual_slim
  end

  def assert_erb_to_slim(given_erb, expected_slim)
    actual_slim = EEx2Slime::EExConverter.new(given_erb).to_s
    assert_equal expected_slim, actual_slim
  end

  def tmp_dir
    @tmp_dir ||= Dir.mktmpdir("html2slime.")
  end

  def create_html_file
    `touch #{html_file}`
  end

  def html_file
    File.join(tmp_dir, "dummy.html")
  end

  def erb_file
    File.join(tmp_dir, "dummy.html.eex")
  end

  def cleanup_tmp_files
    FileUtils.rm_rf(tmp_dir)
  end
end
