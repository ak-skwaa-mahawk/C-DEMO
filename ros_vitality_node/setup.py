from setuptools import setup
from glob import glob

package_name = 'vitality_node'

setup(
    name=package_name,
    version='0.1.0',
    packages=[package_name],
    data_files=[
        ('share/ament_index/resource_index/packages', ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        ('share/' + package_name + '/launch', glob('launch/*.py')),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='John Carroll',
    maintainer_email='ak-skwaa-mahawk@protonmail.com',
    description='Sovereign vitality processor ROS node',
    license='Apache-2.0',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            'vitality_bridge = vitality_node.vitality_bridge:main',
        ],
    },
)