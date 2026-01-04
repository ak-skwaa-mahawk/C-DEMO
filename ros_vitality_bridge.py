import rclpy
from rclpy.node import Node
from std_msgs.msg import Float32, Bool

class VitalityBridge(Node):
    def __init__(self):
        super().__init__('vitality_bridge')
        self.sub = self.create_subscription(Float32, 'vitality', self.callback, 10)
        self.pub = self.create_publisher(Bool, 'motor_cmd', 10)
    
    def callback(self, msg):
        vitality = msg.data
        self.get_logger().info(f"Vitality: {vitality:.2f}")
        
        # Simple rule: high vitality → move
        cmd = vitality > 0.8
        self.pub.publish(Bool(data=cmd))
        self.get_logger().info(f"Motor: {'ON' if cmd else 'OFF'}")

def main():
    rclpy.init()
    node = VitalityBridge()
    rclpy.spin(node)
    rclpy.shutdown()

if __name__ == '__main__':
    main()