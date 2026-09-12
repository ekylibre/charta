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
  spec.add_dependency 'rgeo', '~> 3.1'
  spec.add_dependency 'rgeo-geojson', '~> 2.2'
  # rgeo-proj4 2.x s'appuie sur l'API historique de PROJ.4, retirée dans
  # PROJ 8 : son extension se compile mais n'attache aucune méthode. La série
  # 5.x emploie `proj.h` et exige rgeo ~> 3.1.
  spec.add_dependency 'rgeo-proj4', '~> 5.0'
  spec.add_dependency 'victor', '~> 0.3.3'
  # `~> 2.4.0` bornait au patch près et bloquait la résolution vers Rails 7,
  # dont railties exige `zeitwerk ~> 2.5`. Charta n'emploie que `for_gem`,
  # `inflect` et `setup`, stables depuis la 2.0.
  spec.add_dependency 'zeitwerk', '>= 2.4', '< 3'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '1.3.1'
end
