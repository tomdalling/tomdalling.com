require_relative '../../test_init'

TestBench.context Statue::CLI do
  Statue::CLI.run(Shellwords.split("build"))
end
