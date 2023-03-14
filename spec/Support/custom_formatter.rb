require 'rspec/core/formatters/progress_formatter'

class CustomFormatter < RSpec::Core::Formatters::ProgressFormatter
  def example_passed(example)
    output.print green('.')
    output.puts " #{example.full_description} - #{example.execution_result[:run_time]} seconds - PASSED"
  end
end






