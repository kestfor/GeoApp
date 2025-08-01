import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'marker_cluster_node.dart';

/// Just a base class which MarkerNode and MarkerClusterNode both extend which
/// allows us to restrict arguments to one of those two classes without having
/// to resort to 'dynamic' which can hide bugs.
abstract class MarkerOrClusterNode {
  MarkerClusterNode? parent;

  MarkerOrClusterNode({required this.parent});

  Offset pixelBounds(MapCamera map);
}
