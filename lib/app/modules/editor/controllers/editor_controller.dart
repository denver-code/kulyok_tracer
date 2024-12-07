import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kulyok/app/models/network_nodes.dart';
import 'package:flutter/services.dart';

class EditorController extends GetxController {
  var nodes = <NetworkNode>[].obs;
  var connections = <Map<String, dynamic>>[].obs;
  RxBool isWiringMode = false.obs;
  RxBool isDeletingMode = false.obs;
  RxBool isAutoConnectMode = false.obs;
  var selectedNode = Rx<NetworkNode?>(null);
  var selectedPort = Rx<Port?>(null);
  var isCreatingConnection = false.obs;
  var sourceNode = Rx<NetworkNode?>(null);
  var sourcePort = Rx<Port?>(null);

  // Export the list of nodes and connections
  List<NetworkNode> getNodes() => nodes.toList();
  List<Map<String, dynamic>> getConnections() => connections.toList();

  String _generateRandomId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey.keyLabel;
    if (event is! KeyDownEvent) return false;
    switch (key) {
      case 'L':
        isWiringMode.toggle();
        isDeletingMode.value = false;
      case 'X':
        isDeletingMode.toggle();
        isWiringMode.value = false;
      case 'A':
        isAutoConnectMode.toggle();
      case 'R':
        {
          final newRouter = NetworkNode(
            id: 'router_${nodes.length}_${_generateRandomId()}',
            name: 'Router ${nodes.length + 1}',
            type: 'router',
            ip: '10.0.0.${nodes.length + 1}',
            position: Offset(100, 100 + nodes.length * 50),
          );
          addNode(newRouter);
        }
      default:
        return false;
    }
    return true;
  }

  void openNode(NetworkNode node) {
    // Implementation for opening node details
  }

  void editNode(NetworkNode node) {
    // Implementation for editing node properties
  }

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
    if (isDeletingMode.value) {
      isDeletingMode.toggle();
    }
    isWiringMode.toggle();
    if (!isWiringMode.value) {
      resetWiringState();
    }
  }

  void toggleDeletingMode() {
    if (isWiringMode.value) {
      toggleWiringMode();
    }
    isDeletingMode.toggle();
  }

  void toggleAutoWiringMode() => isAutoConnectMode.toggle();

  void resetWiringState() {
    selectedNode.value = null;
    selectedPort.value = null;
    sourceNode.value = null;
    sourcePort.value = null;
    isCreatingConnection.value = false;
  }

  void handleNodeTap(NetworkNode node) {
    if (isDeletingMode.value) {
      deleteNode(node);
      return;
    }
    if (!isWiringMode.value) return;

    if (!isCreatingConnection.value) {
      // First node selection
      sourceNode.value = node;
      isCreatingConnection.value = true;
      if (isAutoConnectMode.value) {
        var port =
            node.ports.firstWhereOrNull((port) => port.connections.isEmpty);
        sourcePort.value = port;
      } else {
        _showPortSelectionDialog(node, isSource: true);
      }
    } else if (sourceNode.value?.id != node.id) {
      // Second node selection
      selectedNode.value = node;
      if (isAutoConnectMode.value) {
        var port =
            node.ports.firstWhereOrNull((port) => port.connections.isEmpty);
        selectedPort.value = port;
        if (port != null) {
          addConnection(
            sourceNode.value!.id,
            sourcePort.value!.id,
            node.id,
            port.id,
          );
          resetWiringState();
          toggleWiringMode();
        }
      } else {
        _showPortSelectionDialog(node, isSource: false);
      }
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
                    toggleWiringMode();
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

  @override
  void onInit() {
    super.onInit();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void onClose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.onClose();
  }
}
