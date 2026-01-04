import rclpy
from rclpy.node import Node
from std_msgs.msg import Float32, Bool
import numpy as np

class VitalityBridge(Node):
    """
    Sovereign vitality bridge ROS node.
    Subscribes to sensor data, computes vitality, publishes motor command.
    """

    def __init__(self):
        super().__init__('vitality_bridge')
        
        # Parameters (configurable)
        self.declare_parameter('vitality_threshold', 0.8)
        threshold = self.get_parameter('vitality_threshold').value
        
        # Subscribers/Publishers
        self.sub = self.create_subscription(
            Float32, 'sensor_vitality', self.vitality_callback, 10)
        self.pub = self.create_publisher(Bool, 'motor_cmd', 10)
        
        self.threshold = threshold
        self.get_logger().info(f"Vitality Bridge Active | Threshold: {threshold}")

    def vitality_callback(self, msg):
        vitality = msg.data
        self.get_logger().info(f"Received Vitality: {vitality:.2f}")
        
        # Simple control: high vitality → move
        cmd = vitality > self.threshold
        self.pub.publish(Bool(data=cmd))
        self.get_logger().info(f"Motor Command: {'ON' if cmd else 'OFF'}")

def main(args=None):
    rclpy.init(args=args)
    node = VitalityBridge()
    
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()