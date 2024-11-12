import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kulyok/app/models/network_nodes.dart';

class EditorController extends GetxController {
  var nodes = <NetworkNode>[].obs;
  var connections = <Map<String, dynamic>>[].obs;
  var isWiringMode = false.obs;
  var selectedNode = Rx<NetworkNode?>(null);
  var selectedPort = Rx<Port?>(null);
  var isCreatingConnection = false.obs; // Added this state variable
  var sourceNode = Rx<NetworkNode?>(null); // Added to track source node
  var sourcePort = Rx<Port?>(null); // Added to track source port

  void openNode(NetworkNode node) {
    // Implementation for opening node details
  }

  void editNode(NetworkNode node) {
    // Implementation for editing node properties
  }

  /// Deletes a node and all its connections.
  ///
  /// This method removes all the connections that involve the given node,
  /// and then removes the node itself from the list of nodes.
  ///
  /// When a connection is removed, the connected port of the other node is
  /// also updated to remove the connection from its list of connections.
  ///
  /// Finally, the list of nodes and the list of connections are refreshed to
  /// update the UI.
  void deleteNode(NetworkNode node) {
    for (var port in node.ports) {
      for (var connection in port.connections) {
        var connectedNode = nodes.firstWhere((n) => n.id == connection.nodeId);
        var connectedPort =
            connectedNode.ports.firstWhere((p) => p.id == connection.portId);
        connectedPort.connections.removeWhere((conn) => conn.nodeId == node.id);
      }
      port.connections.clear();
    }

    connections.removeWhere((connection) =>
        connection['fromNode'] == node.id || connection['toNode'] == node.id);
    connections.refresh();

    nodes.remove(node);
    nodes.refresh();
  }

  void addNode(NetworkNode node) {
    nodes.add(node);
  }

  void toggleWiringMode() {
    isWiringMode.toggle();
    if (!isWiringMode.value) {
      resetWiringState();
    }
  }

  void resetWiringState() {
    selectedNode.value = null;
    selectedPort.value = null;
    sourceNode.value = null;
    sourcePort.value = null;
    isCreatingConnection.value = false;
  }

  void handleNodeTap(NetworkNode node) {
    if (!isWiringMode.value) return;

    if (!isCreatingConnection.value) {
      // First node selection
      sourceNode.value = node;
      isCreatingConnection.value = true;
      _showPortSelectionDialog(node, isSource: true);
    } else if (sourceNode.value?.id != node.id) {
      // Second node selection
      selectedNode.value = node;
      _showPortSelectionDialog(node, isSource: false);
    }
  }

  void _showPortSelectionDialog(NetworkNode node, {required bool isSource}) {
    Get.dialog(
      AlertDialog(
        title: Text('Select ${isSource ? "Source" : "Destination"} Port'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: node.ports.map((port) {
            bool isPortConnected = port.connections.isNotEmpty;
            return ListTile(
              title:
                  Text('${port.name} ${isPortConnected ? "(Connected)" : ""}'),
              enabled: !isPortConnected,
              onTap: () {
                if (isSource) {
                  // Store the first selection
                  sourcePort.value = port;
                  Get.back();
                } else {
                  // Complete the connection
                  if (sourceNode.value != null && sourcePort.value != null) {
                    addConnection(
                      sourceNode.value!.id,
                      sourcePort.value!.id,
                      node.id,
                      port.id,
                    );
                    Get.back();
                    resetWiringState();
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              if (isSource) {
                resetWiringState();
              }
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void addConnection(
      String fromNodeId, String fromPortId, String toNodeId, String toPortId) {
    // Check if connection already exists
    final exists = connections.any((conn) =>
        (conn['fromNode'] == fromNodeId &&
            conn['fromPort'] == fromPortId &&
            conn['toNode'] == toNodeId &&
            conn['toPort'] == toPortId) ||
        (conn['fromNode'] == toNodeId &&
            conn['fromPort'] == toPortId &&
            conn['toNode'] == fromNodeId &&
            conn['toPort'] == fromPortId));

    if (!exists) {
      // Get node positions
      final fromNode = nodes.firstWhere((node) => node.id == fromNodeId);
      final toNode = nodes.firstWhere((node) => node.id == toNodeId);

      // Determine the side of the connection line
      final fromSide = _getSide(fromNode, toNode);
      final toSide = _getSide(toNode, fromNode);

      // Calculate connection line positions
      final fromPosition = _getPosition(fromNode, fromSide);
      final toPosition = _getPosition(toNode, toSide);

      // Add connection to the connections list with positions
      connections.add({
        'fromNode': fromNodeId,
        'fromPort': fromPortId,
        'toNode': toNodeId,
        'toPort': toPortId,
        'fromPosition': fromPosition,
        'toPosition': toPosition,
      });

      // Update port connections on both nodes
      final fromPort =
          fromNode.ports.firstWhere((port) => port.id == fromPortId);
      final toPort = toNode.ports.firstWhere((port) => port.id == toPortId);

      fromPort.connections.add(Connection(
        nodeId: toNodeId,
        portId: toPortId,
        position: toPosition,
      ));

      toPort.connections.add(Connection(
        nodeId: fromNodeId,
        portId: fromPortId,
        position: fromPosition,
      ));

      nodes.refresh(); // Refresh to update the UI
    }
  }

  String _getSide(NetworkNode node1, NetworkNode node2) {
    if (node1.position.dx < node2.position.dx) {
      return 'right'; // node1 is to the left of node2
    } else if (node1.position.dx > node2.position.dx) {
      return 'left'; // node1 is to the right of node2
    } else if (node1.position.dy < node2.position.dy) {
      return 'bottom'; // node1 is above node2
    } else {
      return 'top'; // node1 is below node2
    }
  }

// Helper method to calculate the position of the connection line
  Offset _getPosition(NetworkNode node, String side) {
    switch (side) {
      case 'left':
        return Offset(node.position.dx, node.position.dy + (75 / 2));
      case 'right':
        return Offset(node.position.dx + 75, node.position.dy + (75 / 2));
      case 'top':
        return Offset(node.position.dx + (75 / 2), node.position.dy);
      case 'bottom':
        return Offset(node.position.dx + (75 / 2), node.position.dy + 75);
      default:
        throw Exception('Invalid side');
    }
  }

  // Add method to update connection positions when nodes move
  void updateNodePosition(String id, Offset newPosition) {
    final index = nodes.indexWhere((node) => node.id == id);
    if (index != -1) {
      nodes[index].position = newPosition;

      // Update all connection positions related to this node
      for (var i = 0; i < connections.length; i++) {
        var connection = connections[i];

        // Calculate center position
        final centerPosition = Offset(
          newPosition.dx + 75,
          newPosition.dy + 60,
        );

        if (connection['fromNode'] == id) {
          connection['fromPosition'] = centerPosition;
        }
        if (connection['toNode'] == id) {
          connection['toPosition'] = centerPosition;
        }
      }

      connections.refresh();
      nodes.refresh();
    }
  }
}
