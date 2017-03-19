require 'rubygems'
require 'tmpdir'
require 'minitest/autorun'
require_relative '../lib/eex2slime'

MiniTest.autorun

class TestEEx2Slime < MiniTest::Test
  def setup
    `touch #{html_file}`
  end

  def teardown
    FileUtils.rm_rf(tmp_dir)
  end

  def test_integrational
    IO.popen("bin/eex2slime test/fixtures/slim_lang.html.eex -", "r") do |f|
      assert_equal File.read("test/fixtures/slim_lang.slime"), f.read
    end

    IO.popen("bin/eex2slime test/fixtures/eex_example.html.eex -", "r") do |f|
      assert_equal File.read("test/fixtures/eex_example.slime"), f.read
    end
  end

  def test_convert_file_to_stdout
    File.open(html_file, "w") do |f|
      f.puts "<p><h1>Hello</h1></p>"
    end

    IO.popen("bin/eex2slime #{html_file} -", "r") do |f|
      assert_equal "p\n  h1\n    | Hello\n", f.read
    end
  end

  def test_convert_stdin_to_stdout
    File.open(html_file, "w") do |f|
      f.puts "<p><h1>Hello</h1></p>"
    end

    IO.popen("cat #{html_file} | bin/eex2slime", "r") do |f|
      assert_equal "p\n  h1\n    | Hello\n", f.read
    end
  end

  # It would be cool to use better indentation for case clauses,
  # but I don't know how to implement it with current gsub'y approach.
  def test_control_flow
    assert_fixture_eex_to_slime("control_flow")
  end

  def test_id_and_class_rules
    assert_fixture_eex_to_slime("id_and_class_rules")
  end

  def test_multiline_function
    assert_fixture_eex_to_slime("multiline_function")
  end

  # Generally you shouldn't write code in this manner.
  # But changelog app (https://github.com/thechangelog/changelog.com),
  # which I used in test purposes, includes code written in such a way.
  # Anyway, thanks them a lot for opensourcing their app.
  def test_end_with_leading_equal_sign
    assert_fixture_eex_to_slime("end_with_leading_equal_sign")
  end

  # Again, strange changelog code style.
  def test_class_with_equal_sign
    assert_fixture_eex_to_slime("class_with_equal_sign")
  end

  def test_interpolation_inside_attributes
    assert_fixture_eex_to_slime("interpolation_inside_attributes")
  end

  # isn't fully supported, but at least output shouldn't contain <elixir> tags
  def test_inline_ifs
    assert_fixture_eex_to_slime("inline_ifs")
  end

  def test_utf_8
    assert_fixture_eex_to_slime("utf-8")
  end

  def test_data_attributes
    html = '<a href="test" data-param1="var" data-param2="(1 + 1)"></a>'
    slim = 'a[href="test" data-param1="var" data-param2="(1 + 1)"]'
    assert_eex_to_slime html, slim
  end

  def test_escaped_text
    text = "this is js code sample.&nbsp; &raquo; &lt;script&gt;&lt;/script&gt;"
    assert_eex_to_slime text, "| #{text}"
  end

  def test_with_leading_dash
    assert_eex_to_slime '<%- test() %>', "- test()"
  end

  def test_does_not_break_code_with_inconsistent_indentation
    assert_fixture_eex_to_slime("inconsistent_indentation")
  end

  def test_does_not_fail_on_empty_lines_inside_code
    assert_fixture_eex_to_slime("empty_lines_inside_code")
  end

  private

  def assert_eex_to_slime(given_erb, expected_slim)
    actual_slim = EEx2Slime.convert_string(given_erb)
    assert_equal expected_slim, actual_slim
  end

  def assert_fixture_eex_to_slime(fixture_name)
    expected = File.read("test/fixtures/#{fixture_name}.slime").strip
    actual = EEx2Slime.convert("test/fixtures/#{fixture_name}.html.eex")
    assert_equal(expected, actual)
  end

  def tmp_dir
    @tmp_dir ||= Dir.mktmpdir("html2slime.")
  end

  def html_file
    File.join(tmp_dir, "dummy.html")
  end

  def erb_file
    File.join(tmp_dir, "dummy.html.eex")
  end
end
