Gem::Specification.new do |s|
  s.name        = "swd"
  s.version     = File.read("VERSION")
  s.authors     = ["nov matake"]
  s.email       = ["nov@matake.jp"]
  s.homepage    = "https://github.com/nov/swd"
  s.summary     = %q{SWD (Simple Web Discovery) Client Library}
  s.description = %q{SWD (Simple Web Discovery) Client Library}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_runtime_dependency "json", ">= 1.4.3"
  s.add_runtime_dependency "httpclient", ">= 2.2.1"
  s.add_runtime_dependency "activesupport", ">= 3"
  s.add_runtime_dependency "i18n"
  s.add_runtime_dependency "attr_required", ">= 0.0.5"
  s.add_development_dependency "rake", ">= 0.8"
  if RUBY_VERSION >= '1.9'
    s.add_development_dependency "cover_me", ">= 1.2.0"
  else
    s.add_development_dependency "rcov", ">= 0.9"
  end
  s.add_development_dependency "rspec", ">= 2"
  s.add_development_dependency "webmock", ">= 1.6.2"
end