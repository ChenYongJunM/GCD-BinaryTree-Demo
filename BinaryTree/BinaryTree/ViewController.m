//
//  ViewController.m
//  BinaryTree
//
//  Created by xindong on 16/3/2.
//  Copyright © 2016年 xindong. All rights reserved.
//

#import "ViewController.h"
#import "Node.h"

@interface ViewController ()
{
    BOOL isInsert;
    NSInteger depath;
}
@property (nonatomic, strong) Node *rootNode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    depath = 0;
    self.rootNode = [Node nodeWithName:@"A"];
    
    Node *lastNode = [Node nodeWithName:@"H"];
    // 插入节点
    [self insertNodeTree:self.rootNode node:[Node nodeWithName:@"B"]];
    [self insertNodeTree:self.rootNode node:[Node nodeWithName:@"C"]];
    [self insertNodeTree:self.rootNode node:[Node nodeWithName:@"D"]];
    [self insertNodeTree:self.rootNode node:[Node nodeWithName:@"E"]];
    [self insertNodeTree:self.rootNode node:[Node nodeWithName:@"F"]];
    [self insertNodeTree:self.rootNode node:[Node nodeWithName:@"G"]];
    [self insertNodeTree:self.rootNode node:lastNode];
    
    
    // 遍历二叉树
    [self treeFirstInfomationWithNode:self.rootNode];
    NSLog(@"\n先序遍历\n");
    [self treeMiddleInfomationWithNode:self.rootNode];
    NSLog(@"\n中序遍历\n");
    [self treeLastInfomationWithNode:self.rootNode];
    NSLog(@"\n后续遍历\n");
    [self levelTraverseTree:self.rootNode];
    NSLog(@"\n层次遍历\n");
    
    NSLog(@"\n树深度%ld\n",[self depathOfTree:self.rootNode]);
    NSLog(@"\n所有节点数%ld\n",[self numberOfNodesInTree:self.rootNode]);
    
    
    NSLog(@"%@",[self pathOfTreeNode:lastNode inTree:self.rootNode]);
    
    
    NSLog(@"%d",[self text:self.rootNode]);
    
    
    NSArray *data = @[];
    data[0];
}

/**
 *  往根节点插入节点
 *
 *  @param rootNode 根节点
 *  @param node     被插入的节点
 */
- (void)insertNodeTree:(Node *)rootNode node:(Node *)node
{
    if (rootNode.leftNode == nil) {
        rootNode.leftNode = node;
        return;
    }
    if (rootNode.rightNode == nil) {
        rootNode.rightNode = node;
        return;
    }
    //如果根节点已满，则以其左节点作为下一个根节点继续插入左右两个节点。
    isInsert = !isInsert;
    if (isInsert) {
        [self insertNodeTree:rootNode.rightNode node:node];
    }else{
        [self insertNodeTree:rootNode.leftNode node:node];
    }
}

/**
 *  遍历二叉树 -- 先序遍历
 *
 *  @param node 根节点
 */
- (void)treeFirstInfomationWithNode:(Node *)rootNode
{
//    NSLog(@"先序遍历：%@", rootNode.nodeName);
//    if (rootNode.leftNode) {
//        [self treeFirstInfomationWithNode:rootNode.leftNode];
//    }
//    if (rootNode.rightNode) {
//        [self treeFirstInfomationWithNode:rootNode.rightNode];
//    }
    
    
    NSLog(@"先序遍历：%@", rootNode.nodeName);
    if (rootNode) {
        [self treeFirstInfomationWithNode:rootNode.leftNode];
        [self treeFirstInfomationWithNode:rootNode.rightNode];
    }
}

/**
 *  遍历二叉树 -- 中序遍历
 *
 *  @param node 根节点
 */
- (void)treeMiddleInfomationWithNode:(Node *)rootNode
{
//    if (rootNode.leftNode) {
//        [self treeMiddleInfomationWithNode:rootNode.leftNode];
//    }
//    NSLog(@"中序遍历：%@", rootNode.nodeName);
//    if (rootNode.rightNode) {
//        [self treeMiddleInfomationWithNode:rootNode.rightNode];
//    }
    
    if (rootNode) {
        [self treeMiddleInfomationWithNode:rootNode.leftNode];
        NSLog(@"中序遍历：%@", rootNode.nodeName);
        [self treeMiddleInfomationWithNode:rootNode.rightNode];
    }
}

/**
 *  遍历二叉树 -- 后序遍历
 *
 *  @param node 根节点
 */
- (void)treeLastInfomationWithNode:(Node *)rootNode
{
//    if (rootNode) {
//        [self treeLastInfomationWithNode:rootNode.leftNode];
//        [self treeLastInfomationWithNode:rootNode.rightNode];
//        NSLog(@"后序遍历：%@", rootNode.nodeName);
//    }
    if (rootNode.leftNode) {
        [self treeLastInfomationWithNode:rootNode.leftNode];
    }
    if (rootNode.rightNode) {
        [self treeLastInfomationWithNode:rootNode.rightNode];
    }
    NSLog(@"后序遍历：%@", rootNode.nodeName);
}

- (void)levelTraverseTree:(Node *)rootNode
{
    if (!rootNode) {
        return;
    }
    
    NSMutableArray *queueArr = @[].mutableCopy;
    [queueArr addObject:rootNode];
    
    while (queueArr.count > 0) {
        Node *node = queueArr[0];
        NSLog(@"%@",node.nodeName);
        
        [queueArr removeObjectAtIndex:0];
        if (node.leftNode) {
            [queueArr addObject:node.leftNode];
        }
        if (node.rightNode) {
            [queueArr addObject:node.rightNode];
        }
    }
}

//二叉树深度
- (NSInteger)depathOfTree:(Node *)rootNode
{
    if (!rootNode) {
        return 0;
    }
    if (!rootNode.leftNode && !rootNode.rightNode) {
        return 1;
    }
    
    NSInteger leftDepth = [self depathOfTree:rootNode.leftNode];
    NSInteger rightDepth = [self depathOfTree:rootNode.rightNode];
    
    return MAX(leftDepth, rightDepth) + 1;
}

//二叉树所有节点数
- (NSInteger)numberOfNodesInTree:(Node *)rootNode {
    if (!rootNode) {
        return 0;
    }
    
    //节点数=左子树节点数+右子树节点数+1（根节点）
    return [self numberOfNodesInTree:rootNode.leftNode] + [self numberOfNodesInTree:rootNode.rightNode] + 1;
}

- (NSInteger)text:(Node *)rootNode;
{
    if (!rootNode) {
        return 0;
    }else{
        NSInteger left = [self text:rootNode.leftNode];
        NSInteger right = [self text:rootNode.rightNode];
        
        return left + right + 1;
    }
//    return 0;
}

//二叉树中某个节点到根节点的路径
- (NSArray *)pathOfTreeNode:(Node *)treeNode inTree:(Node *)rootNode {
    NSMutableArray *pathArray = [NSMutableArray array];
    [self isFoundTreeNode:treeNode inTree:rootNode routePath:pathArray];
    return pathArray;
}

- (BOOL)isFoundTreeNode:(Node *)treeNode inTree:(Node *)rootNode routePath:(NSMutableArray *)path {
    
    if (!rootNode || !treeNode) {
        return NO;
    }
    //找到节点
    if (rootNode == treeNode) {
        [path addObject:rootNode];
        return YES;
    }
    //压入根节点，进行递归
    [path addObject:rootNode];
    //先从左子树中查找
    BOOL find = [self isFoundTreeNode:treeNode inTree:rootNode.leftNode routePath:path];
    //未找到，再从右子树查找
    if (!find) {
        find = [self isFoundTreeNode:treeNode inTree:rootNode.rightNode routePath:path];
    }
    //如果2边都没查找到，则弹出此根节点
    if (!find) {
        [path removeLastObject];
    }
    
    return find;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
