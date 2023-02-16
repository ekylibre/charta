# Gathers geomatic calculations
# Completes RGeo
require 'bigdecimal'
require 'bigdecimal/util'
require 'rgeo'
require 'rgeo/proj4'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem # Zeitwerk 2.6+ (warn_on_extra_files: false)
loader.inflector.inflect(
  'geo_json' => 'GeoJSON',
  'gml' => 'GML',
  'kml' => 'KML'
)
loader.setup

unless RGeo::CoordSys::Proj4.supported?
  puts "Proj4 is not supported. Some actions won't work"
end

# Charta aims to supply easy geom/geog tools
module Charta
  SRS = {
    WGS84: 4326,
    CRS84: 4326,
    RGF93: 2143
  }.freeze

  class << self
    def default_feature_factory=(factory)
      @default_feature_factory = factory
      @geometry_factory = nil
    end

    # @deprecated This is deprecated and will be removed in 0.4
    def default_feature_factory
      @default_feature_factory || (self.default_feature_factory = Factory::SimpleFeatureFactory.build)
    end

    def geometry_factory
      @geometry_factory ||= Factory::SimpleGeometryFactory.new(feature_factory: default_feature_factory)
    end

    # @deprecated This is deprecated and will be removed in 0.4
    def new_feature(coordinates, srs = nil, format = nil, _flatten_collection = true, _options = {})
      default_feature_factory.new_feature(coordinates, srs: srs, format: format)
    end

    def new_geometry(coordinates, srs = nil, format = nil, _flatten_collection = true, _options = {})
      geometry_factory.new_geometry(coordinates, srs: srs, format: format)
    end

    def new_point(lat, lon, srid = 4326)
      feature = Charta.new_feature("SRID=#{srid};POINT(#{lon} #{lat})")
      Point.new(feature)
    end

    def make_line(points, options = {})
      options[:srid] ||= new_geometry(points.first).srid if points.any?
      options[:srid] ||= 4326

      points_coordinates = points.map do |wkt|
        p = new_geometry(wkt)

        "#{p.x} #{p.y}"
      end

      ewkt = "SRID=#{options[:srid]};LINESTRING(#{points_coordinates.join(', ')})"
      new_geometry(ewkt)
    end

    def empty_geometry(srid = :WGS84)
      geometry_factory.empty_geometry(srid)
    end

    def generate_ewkt(feature)
      generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt, emit_ewkt_srid: true)
      generator.generate(feature)
    end

    def parse_ewkt(coordinates)
      # parser = RGeo::WKRep::WKTParser.new(factory, support_ewkt: true)
      # factory.parse_wkt(coordinates)
      coordinates
    end

    def find_system_by_srid(_srid)
      nil
    end

    def find_system_by_urn(_urn)
      nil
    end

    def find_system(_srname)
      nil
    end

    # Check and returns the SRID matching with srname or SRID.
    # @deprecated
    def find_srid(srname_or_srid)
      Factory::SridProvider.build.find(srname_or_srid)
    end

    def from(format, data)
      unless respond_to?("from_#{format}")
        raise "Unknown format: #{format.inspect}"
      end

      send("from_#{format}", data)
    end

    def from_gml(data, srid = nil, flatten_collection = false)
      new_geometry(::Charta::GML.new(data, srid).to_ewkt, nil, nil, flatten_collection)
    end

    def from_kml(data, flatten_collection = false)
      new_geometry(::Charta::KML.new(data).to_ewkt, nil, nil, flatten_collection)
    end

    def from_geojson(data, srid = nil)
      new_geometry(::Charta::GeoJSON.new(data, srid).to_ewkt)
    end

    # Utility methods

    def underscore(text)
      text.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
    end

    def camelcase(text, first_letter = :upper)
      ret = text.split(/[_\-]+/).map { |word| word[0..0].upcase + word[1..-1].downcase }.join
      ret = text[0..0].downcase + text[1..-1] if first_letter == :lower
      ret
    end
  end
end
