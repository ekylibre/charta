require 'test_helper'

module Charta
  class MultiPolygonTest < Charta::Test
    def test_polygons
      # Le trou est intérieur à l'enveloppe. L'ancienne version du test le
      # plaçait à l'extérieur — une géométrie invalide, que rgeo 3 refuse
      # désormais de comparer. Ce que ce test vérifie, c'est que `polygons`
      # rend les polygones constitutifs, pas le traitement de l'invalide.
      geom = Charta.new_geometry('MULTIPOLYGON(((10 10,50 10,50 50,10 50,10 10), (20 20,30 20,30 30,20 30,20 20)))', 4326)
      assert_equal Charta::MultiPolygon, geom.class
      assert_equal [Charta.new_geometry('POLYGON((10 10,50 10,50 50,10 50,10 10), (20 20,30 20,30 30,20 30,20 20))')], geom.polygons
    end
  end
end
