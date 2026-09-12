# Les implémentations GEOS de RGeo déclarent `simplify`,
# `simplify_preserve_topology` et `buffer_with_style` dans
# `CAPIGeometryMethods` / `FFIGeometryMethods`. Or `ValidityCheck` n'enveloppe
# que les méthodes déclarées par un ancêtre descendant de
# `RGeo::Feature::Geometry` : ces trois-là n'obtiennent donc pas la doublure
# `unsafe_*` que la bibliothèque pose sur toutes les autres opérations.
#
# `RGeo::Geographic::ProjectedFeatureMethods` les appelle pourtant sous ce nom.
# Toute géométrie issue d'une fabrique projetée — celle que `Charta::Geometry`
# construit pour le SRID 4326 — lève donc `NoMethodError: undefined method
# 'unsafe_simplify'` sous rgeo 3.1.
#
# On se contente de poser les alias manquants : la méthode publique garde son
# comportement, et aucune vérification de validité n'est ajoutée là où RGeo n'en
# demande pas — `simplify(0)` sert justement, chez nous, à rattraper des formes
# douteuses.
module RGeo
  module GeosUnsafeAliases
    METHODS = %i[buffer_with_style simplify simplify_preserve_topology].freeze

    class << self
      def install(mod)
        METHODS.each do |name|
          next unless mod.method_defined?(name)

          unsafe = :"unsafe_#{name}"
          next if mod.method_defined?(unsafe)

          mod.send(:alias_method, unsafe, name)
        end
      end
    end
  end
end

RGeo::GeosUnsafeAliases.install(RGeo::Geos::CAPIGeometryMethods) if defined?(RGeo::Geos::CAPIGeometryMethods)
RGeo::GeosUnsafeAliases.install(RGeo::Geos::FFIGeometryMethods) if defined?(RGeo::Geos::FFIGeometryMethods)
