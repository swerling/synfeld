# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{synfeld}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steven Swerling"]
  s.date = %q{2009-07-18}
  s.description = %q{Synfeld is an application framework that does almost nothing, and it ain't all that classy.  

Basically this is just a tiny wrapper for the Rack::Router (see http://github.com/carllerche/rack-router)

Very alpha-ish stuff here. Seems to work though.}
  s.email = %q{sswerling@yahoo.com}
  s.extra_rdoc_files = ["History.txt", "README.txt"]
  s.files = [".gitignore", "History.txt", "README.txt", "Rakefile", "example/foo_app.rb", "example/foo_app.ru", "lib/synfeld.rb", "lib/synfeld/base.rb", "lib/synfeld_info.rb", "spec/spec_helper.rb", "spec/synfeld_spec.rb", "synfeld.gemspec", "test/test_synfeld.rb"]
  s.homepage = %q{http://tab-a.slot-z.net}
  s.rdoc_options = ["--inline-source", "--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{synfeld}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Synfeld is an application framework that does almost nothing, and it ain't all that classy}
  s.test_files = ["test/test_synfeld.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_runtime_dependency(%q<rack-router>, [">= 0"])
      s.add_development_dependency(%q<bones>, [">= 2.4.0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<rack-router>, [">= 0"])
      s.add_dependency(%q<bones>, [">= 2.4.0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<rack-router>, [">= 0"])
    s.add_dependency(%q<bones>, [">= 2.4.0"])
  end
end
