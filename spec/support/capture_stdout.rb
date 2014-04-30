module CaptureStdout
  def capture_stdout(&block)
    old_stdout = $stdout
    $stdout = stdout = StringIO.new

    yield
    stdout.string
  ensure
    $stdout = old_stdout
  end

  def capture_stdout_lines(&block)
    capture_stdout(&block).lines("\n")
  end
end

RSpec.configure do |config|
  include CaptureStdout
end
