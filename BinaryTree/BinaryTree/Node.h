//
//  Node.h
//  BinaryTree
//
//  Created by xindong on 16/3/2.
//  Copyright © 2016年 xindong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Node : NSObject

// 当前节点的名字
@property (nonatomic, strong) NSString *nodeName;

// 左节点
@property (nonatomic, strong) Node *leftNode;

// 右节点
@property (nonatomic, strong) Node *rightNode;

// 便利构造器
+ (instancetype)nodeWithName:(NSString *)nodeName;

@end
