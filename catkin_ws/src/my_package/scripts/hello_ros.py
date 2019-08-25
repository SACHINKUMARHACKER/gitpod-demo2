#!/usr/bin/env python

import rospy

def main():
    rospy.init_node('demo_ros')
    rate = rospy.Rate(10) # hz

    while not rospy.is_shutdown():
        rospy.loginfo('this is working')
        rate.sleep()


main()