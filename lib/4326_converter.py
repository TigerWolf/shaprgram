#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, os
import inspect
from qgis.core import *

if len(sys.argv) != 3:
  sys.exit('Usage: python 4326_converter.py vector_file.shp 4326_srid_output.shp')

if not os.path.exists(sys.argv[1]):
  sys.exit('ERROR: Input file %s was not found!' % sys.argv[1])

QgsApplication.setPrefixPath("/Applications/QGIS.app/Contents/MacOS", True) # '/usr' on ubuntu
QgsApplication.initQgis()
# providers = QgsProviderRegistry.instance().providerList()

layer = QgsVectorLayer(sys.argv[1], "vector_layer", "ogr");
error = QgsVectorFileWriter.writeAsVectorFormat(layer, sys.argv[2], "CP1250", QgsCoordinateReferenceSystem(4326), "ESRI Shapefile");

if error == QgsVectorFileWriter.NoError:
  print "success!"

