# frozen_string_literal: true

module Charta
  module Factory
    class EwktFeatureBuilder
      class << self
        # @param [Numeric, #to_i] srid
        def factory_for(srid)
          if srid.to_i == 4326
            projected_factory(srid)
          else
            geos_factory(srid)
          end
        end

        private

          def geos_factory(srid)
            RGeo::Geos.factory(
              srid: srid,
              wkt_generator: {
                type_format: :ewkt,
                emit_ewkt_srid: true,
                convert_case: :upper
              },
              wkt_parser: {
                support_ewkt: true
              },
              wkb_generator: {
                type_format: :ewkb,
                emit_ewkb_srid: true,
                hex_format: true
              },
              wkb_parser: {
                support_ewkb: true
              }
            )
          end

          def projected_factory(srid)
            proj4 = '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs'

            RGeo::Geographic.projected_factory(
              srid: srid,
              wkt_generator: {
                type_format: :ewkt,
                emit_ewkt_srid: true,
                convert_case: :upper
              },
              wkt_parser: {
                support_ewkt: true
              },
              wkb_generator: {
                type_format: :ewkb,
                emit_ewkb_srid: true,
                hex_format: true
              },
              wkb_parser: {
                support_ewkb: true
              },
              projection_srid: 6933,
              projection_proj4: proj4
            )
          end
      end

      # @param [String] ewkt EWKT representation of a feature
      # @return [RGeo::Feature::Instance]
      def from_ewkt(ewkt)
        if ewkt.to_s =~ /\A[[:space:]]*\z/
          raise ArgumentError.new("Invalid data: #{ewkt.inspect}")
        end

        # Cleans empty geometries
        ewkt = ewkt.gsub(/(GEOMETRYCOLLECTION|GEOMETRY|((MULTI)?(POINT|LINESTRING|POLYGON)))\(\)/, '\1 EMPTY')
        srs = ewkt.split(/[\=\;]+/)[0..1]
        srid = nil
        srid = srs[1] if srs[0] =~ /srid/i
        srid ||= 4326

        EwktFeatureBuilder.factory_for(srid).parse_wkt(ewkt)
      rescue RGeo::Error::ParseError => e
        raise "Invalid EWKT (#{e.class.name}: #{e.message}): #{ewkt}"
      end
    end
  end
end
