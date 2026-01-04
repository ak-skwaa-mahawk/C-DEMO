from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        Node(
            package='vitality_node',
            executable='vitality_bridge',
            name='vitality_bridge',
            parameters=[{'vitality_threshold': 0.8}]
        )
    ])