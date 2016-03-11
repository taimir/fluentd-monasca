# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Sepcification.new do |spec|
  spec.name = 'fluentd-monasca-output'
  spec.version = '0.0.1'
  spec.license = ['Apache License 2.0']
  spec.authors = ['Fujitsu Enabling Software Technology GmbH']
  spec.email = ['atanas.mirchev@est.fujitsu.com']
  spec.description = 'Monasca output plugin for fluentd'
  spec.summary = spec.description
  spec.homepage = 'https://github.com/taimir/fluentd-monasca'

  spec.files = Dir['lib/**/*', 'spec/**/*', '*.gemspec', '*.md', 'Gemfile', 'LICENSE']
  spec.executables = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files = s.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'fluentd', '>= 0.10.43'
  spec.add_runtime_dependency 'rest-client', '~> 1.8'
  spec.add_runtime_dependency 'logstash-output-monasca_log_api', '~> 0.3.3'

  spec.add_development_dependency 'rake', '>= 0'
  spec.add_development_dependency 'webmock', '~> 1'
  spec.add_development_dependency 'test-unit', '~> 3.1.0'
end