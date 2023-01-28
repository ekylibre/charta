module Charta
  # Represent a Geometry with contains only polygons
  class Polygon < Geometry
    def exterior_ring
      unless defined? @exterior_ring
        generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt, emit_ewkt_srid: true)
        @exterior_ring = Charta.new_geometry(generator.generate(feature.exterior_ring))
      end
      @exterior_ring
    end

    def distance(point)
      polygon_centroid = Charta.new_point(*centroid, 4326)
      polygon_centroid.distance(point)
    end

    def without_hole_outside_shell
      sql = <<-SQL
        SELECT ST_AsText(
                 ST_MakePolygon(
                   ST_ExteriorRing(:feature)
                 )
               ) AS simplfied_shape
      SQL
      query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, feature: feature.as_text])
      simplfied_shape_text = ActiveRecord::Base.connection.execute(query).first['simplfied_shape']
      Charta.new_geometry(simplfied_shape_text)
    end

    def hole_outside_shell?
      sql = <<-SQL
        SELECT St_IsValidreason(:feature) AS reason
      SQL
      query = ActiveRecord::Base.send(:sanitize_sql_array, [sql, feature: feature.as_text])
      result = ActiveRecord::Base.connection.execute(query).first['reason']
      result.start_with?("Hole lies outside shell")
    end
  end
end
