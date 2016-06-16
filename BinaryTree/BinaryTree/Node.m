//
//  Node.m
//  BinaryTree
//
//  Created by xindong on 16/3/2.
//  Copyright © 2016年 xindong. All rights reserved.
//

#import "Node.h"

@implementation Node

+ (instancetype)nodeWithName:(NSString *)nodeName
{
    Node *node = [[super alloc] init];
    node.nodeName = nodeName;
    return node;
}

@end
