require_relative 'helper'
require 'tmpdir'

class TestHTML2Slim < MiniTest::Test
  def setup
    create_html_file
  end

  def teardown
    cleanup_tmp_files
  end

  Dir.glob("test/fixtures/*.html").each do |file|
    define_method("test_template_#{File.basename(file, '.html')}") do
      assert_valid_from_html?(file)
    end
  end

  Dir.glob("test/fixtures/*.html.erb").each do |file|
    define_method("test_template_#{File.basename(file, '.html')}") do
      assert_valid_from_erb?(file)
    end
  end

  def test_id_and_class_rules
    IO.popen("bin/html2slim test/fixtures/id_and_class_rules.html -", "r") do |f|
      assert_equal File.read("test/fixtures/id_and_class_rules.slim"), f.read
    end
  end

  def test_convert_slim_lang_html
    IO.popen("bin/html2slim test/fixtures/slim-lang.html -", "r") do |f|
      assert_equal File.read("test/fixtures/slim-lang.slim"), f.read
    end
  end

  def test_convert_slim_lang_html
    IO.popen("bin/html2slim test/fixtures/slim-lang.html -", "r") do |f|
      assert_equal File.read("test/fixtures/slim-lang.slim"), f.read
    end
  end

  def test_convert_erb
    IO.popen("bin/erb2slim test/fixtures/erb-example.html.erb -", "r") do |f|
      assert_equal File.read("test/fixtures/erb-example.html.slim"), f.read
    end
  end

  def test_convert_multiline_block
    IO.popen("bin/erb2slim test/fixtures/multiline_block.erb -", "r") do |f|
      assert_equal File.read("test/fixtures/multiline_block.slim"), f.read
    end
  end

  # It would be cool to use better indentation for case clauses,
  # but I don't know how to implement it with current gsubby approach.
  def test_convert_elsif_block
    IO.popen("bin/erb2slim test/fixtures/erb_elsif.erb -", "r") do |f|
      assert_equal File.read("test/fixtures/erb_elsif.slim"), f.read
    end
  end

  def test_convert_file_to_stdout
    File.open(html_file, "w") do |f|
      f.puts "<p><h1>Hello</h1></p>"
    end

    IO.popen("bin/html2slim #{html_file} -", "r") do |f|
      assert_equal "p\n  h1\n    | Hello\n", f.read
    end
  end

  def test_convert_stdin_to_stdout
    File.open(html_file, "w") do |f|
      f.puts "<p><h1>Hello</h1></p>"
    end

    IO.popen("cat #{html_file} | bin/html2slim", "r") do |f|
      assert_equal "p\n  h1\n    | Hello\n", f.read
    end
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
    actual_slim = HTML2Slim::HTMLConverter.new(given_html).to_s
    assert_equal expected_slim, actual_slim
  end

  def assert_erb_to_slim(given_erb, expected_slim)
    actual_slim = HTML2Slim::ERBConverter.new(given_erb).to_s
    assert_equal expected_slim, actual_slim
  end

  def tmp_dir
    @tmp_dir ||= Dir.mktmpdir("html2slim.")
  end

  def create_html_file
    `touch #{html_file}`
  end

  def html_file
    File.join(tmp_dir, "dummy.html")
  end

  def erb_file
    File.join(tmp_dir, "dummy.html.erb")
  end

  def cleanup_tmp_files
    FileUtils.rm_rf(tmp_dir)
  end

  def assert_valid_from_html?(source)
    html = File.open(source)
    slim = HTML2Slim.convert!(html)
    assert_instance_of String, Slim::Engine.new.call(slim.to_s)
  end

  def assert_valid_from_erb?(source)
    html = File.open(source)
    slim = HTML2Slim.convert!(html, :erb)
    assert_instance_of String, Slim::Engine.new.call(slim.to_s)
  end
end
