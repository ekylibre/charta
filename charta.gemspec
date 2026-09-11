require_relative 'lib/charta/version'

Gem::Specification.new do |spec|
  spec.name = 'charta'
  spec.version = Charta::VERSION
  spec.authors = ['Ekylibre developers']
  spec.email = ['dev@ekylibre.com']

  spec.summary = 'Simple tool over geos and co'
  spec.required_ruby_version = '>= 2.6.0'
  spec.homepage = 'https://gitlab.com/ekylibre'
  spec.license = 'AGPL-3.0-only'

  spec.files = Dir.glob(%w[lib/**/*.rb *.gemspec])

  spec.require_paths = ['lib']

  # Borne relâchée pour la montée (lot B.2 du plan v6 d'Ekylibre).
  # Couplage mesuré avant : 1 738 lignes, zéro référence aux internes de Rails
  # — le seul lien est un `require 'active_support/core_ext'`.
  spec.add_dependency 'activesupport', '>= 5.0', '< 9'
  spec.add_dependency 'json', '>= 1.8.0'
  spec.add_dependency 'nokogiri', '>= 1.7.0'
  spec.add_dependency 'rgeo', '~> 2.0'
  spec.add_dependency 'rgeo-geojson', '~> 2.0'
  spec.add_dependency 'rgeo-proj4', '~> 2.0'
  spec.add_dependency 'victor', '~> 0.3.3'
  spec.add_dependency 'zeitwerk', '~> 2.4.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '1.3.1'
end
