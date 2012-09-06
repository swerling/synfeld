# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "synfeld"
  s.version = "0.0.6"
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Steven Swerling"]
  s.email = "sswerling@yahoo.com"
  s.homepage = "http://github.com/swerling/synfeld"
  s.summary = "Synfeld is a web application framework that does practically nothing"
  s.rubyforge_project = "synfeld"

  #s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.description = %q{
Synfeld is a web application framework that does practically nothing.

Synfeld is little more than a small wrapper for Rack::Mount (see
http://github.com/josh/rack-mount).  If you want a web framework that is
mostly just going to serve up json blobs, and occasionally serve up some
simple content (eg. help files) and media, Synfeld makes that easy.

The sample app below shows pretty much everything there is to know about
synfeld, in particular:

* How to define routes.
* Simple rendering of erb, haml, html, json, and static files.
* In the case of erb and haml, passing variables into the template is
demonstrated.
* A dynamic action where the status code, headers, and body are created
'manually' (/my/special/route below)
* A simple way of creating format sensitive routes (/alphabet.html vs.
/alphabet.json)
* The erb demo link also demos the rendering of a partial (not visible in the
code below, you have to look at the template file
  examples/public/erb_files/erb_test.erb).
}
  s.extra_rdoc_files = ["History.txt", "README.rdoc", "README.txt"]
  s.files =  `git ls-files`.split("\n")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  #s.require_paths = ["lib"]

  s.rdoc_options = ["--inline-source", "--main", "README.txt"]
  s.require_paths = ["lib"]
  s.test_files = ["test/test_synfeld.rb"]

  #s.add_development_dependency "rake"

  # Cant seem to get bundler to work if I add these 2:
  #$s.add_dependency 'rack' '>=1.4.1'
  #$s.add_dependency 'rack-mount' '>=0.8.3'
end
