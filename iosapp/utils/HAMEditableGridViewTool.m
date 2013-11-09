//
//  HAMDragableViewTool.m
//  iosapp
//
//  Created by Dai Yue on 13-10-25.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMEditableGridViewTool.h"

@implementation HAMEditableGridViewTool

#pragma mark -
#pragma mark View

-(void)refreshView:(NSString*)nodeUUID{
    [super prepareRefreshView:nodeUUID];
    
    cardViewArray_ = [NSMutableArray array];
    editButtonArray_ = [NSMutableArray array];
    
    int childIndex=0,posIndex,pageIndex;
    HAMCard* card = [config card:nodeUUID];
    Boolean isRoot = [card.UUID isEqualToString:config.rootID];
    int btnsPerPage = viewInfo.xnum * viewInfo.ynum;
    
    for (pageIndex = 0; pageIndex < totalPageNum; pageIndex++) {
        posIndex = 0;
        //add home btn
        if (!isRoot)
        {
            [self addButtonWithi:0 j:0 onPage:pageIndex picName:@"back.png" action:@selector(groupClicked:) tag:-1 bgType:-1];
            [self addLabelWithi:0 j:0 onPage:pageIndex text:@"返回" color:[UIColor blackColor] tag:-1];
            posIndex=1;
        }
        //add else btn
        
        for(; posIndex < btnsPerPage; childIndex++,posIndex++)
        {
            NSString* childID=[config childOf:card.UUID at:childIndex];
            
            if(!childID || (NSNull*)childID==[NSNull null])
            {
                isBlankAtTag_[childIndex] = YES;
                [self addAddNodeAtPos:posIndex onPage:pageIndex index:childIndex];
                continue;
            }
            
            isBlankAtTag_[childIndex] = NO;
            [self addCardAtPos:posIndex onPage:pageIndex cardID:childID index:childIndex];
            [self addEditButtonAtPos:posIndex onPage:pageIndex tag:childIndex];
        }
    }
}

- (UIButton*)addButtonWithi:(int)i j:(int)j onPage:(int)pageIndex picName:(NSString*)picName action:(SEL)action tag:(int)tag bgType:(int)bgType
{
    UIButton* button = [super addButtonWithi:i j:j onPage:pageIndex picName:picName action:action tag:tag bgType:bgType];
    //don't add return button
    if (tag == -1)
        return button;
    
    [HAMTools setObject:button toMutableArray:cardViewArray_ atIndex:tag];
    
    CALayer* buttonLayer = [layerArray objectAtIndex:tag];
    positionArray_[tag] = buttonLayer.position;
    tagOfIndex_[tag] = tag;
    
    if (isBlankAtTag_[tag]) {
        return button;
    }
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePan:)];
    [button addGestureRecognizer:panGestureRecognizer];
    return nil;
}

- (void)addAddNodeAtPos:(int)pos onPage:(int)pageIndex index:(int)index
{
    int xid=pos/viewInfo.xnum;
    int yid=pos%viewInfo.xnum;
    
    [self addButtonWithi:xid j:yid onPage:pageIndex picName:@"add.png" action:@selector(addClicked:) tag:index bgType:-1];
    [self addLabelWithi:xid j:yid onPage:pageIndex text:@"新增词条/分组" color:[UIColor blackColor] tag:index];
}

- (void)addEditButtonAtPos:(int)pos onPage:(int)pageIndex tag:(int)tag
{
    UIView* pageView = [pageViews objectAtIndex:pageIndex];
    
    UIButton* editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGPoint position = [viewInfo positionAtPosIndex:pos];
    double length = viewInfo.a * 0.25;
    position.x += viewInfo.a - length;
    editButton.frame = CGRectMake(position.x, position.y, length, length);
    editButton.backgroundColor = [UIColor whiteColor];
    editButton.tag = tag;
    [editButton addTarget:viewController_ action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer * downButtonLayer = [editButton layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setCornerRadius:20.0];
    [downButtonLayer setBorderWidth:1.0];
    [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
    
    [pageView addSubview:editButton];
    [editButtonArray_ addObject:editButton];
}

#pragma mark -
#pragma mark Actions

-(void)moveView:(UIView*)targetView andLayer:(CALayer*)targetLayer toPosition:(CGPoint)position animated:(Boolean)animated{
    if (!animated) {
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    }
    
    targetView.center = position;
    if (targetLayer)
        targetLayer.position = position;
    
    if (!animated) {
        [CATransaction commit];
    }
}

- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    if (editButtonArray_){
        for (int i = 0; i<[editButtonArray_ count]; i++) {
            [[editButtonArray_ objectAtIndex:i] removeFromSuperview];
        }
        editButtonArray_ = nil;
    }
    
    UIView* cardView = recognizer.view;
    int tag = cardView.tag;
    
    CGPoint newPosition = cardView.center;
    CGPoint translation = [recognizer translationInView:viewController_.view];
    [recognizer setTranslation:CGPointZero inView:viewController_.view];
    newPosition.x += translation.x;
    newPosition.y += translation.y;
    
    //move card
    CALayer* cardLayer = [layerArray objectAtIndex:tag];
    //TODO: don't repeat this for efficiency
    CALayer* superLayer = [cardLayer superlayer];
    [cardLayer removeFromSuperlayer];
    [superLayer addSublayer:cardLayer];
    
    [self moveView:cardView andLayer:cardLayer toPosition:newPosition animated:NO];
        
    //get current index
    int currentIndex;
    int i;
    int cardnum = [layerArray count];
    for (i=0; i<cardnum; i++) {
        if (tagOfIndex_[i] == tag){
            currentIndex = i;
            break;
        }
    }
    
    //find nearest
    double minDist = MAXFLOAT;
    int nearestIndex;
    for (i=0; i<cardnum; i++) {
        CGPoint position = positionArray_[i];
        double dist = (newPosition.x - position.x)*(newPosition.x - position.x) + (newPosition.y - position.y)*(newPosition.y - position.y);
        if (minDist > dist){
            minDist = dist;
            nearestIndex = i;
        }
    }
    
    //move other cards
    int newTagOfIndex[MAX_CARD_NUM];
    for (i=0; i<cardnum; i++){
        newTagOfIndex[i] = tagOfIndex_[i];
    }
    newTagOfIndex[nearestIndex] = tag;
    
    //sequential move solution:
    int inc = currentIndex > nearestIndex ? 1 : -1;
    for (i=nearestIndex; i!=currentIndex; i+=inc) {
        int targetTag = tagOfIndex_[i];
        UIView* targetView = [cardViewArray_ objectAtIndex:targetTag];
        CALayer* targetLayer = [layerArray objectAtIndex:targetTag];
        if (isBlankAtTag_[targetTag]){
            [self moveView:targetView andLayer:targetLayer toPosition:positionArray_[currentIndex] animated:NO];
            newTagOfIndex[currentIndex] = targetTag;
            break;
        }
        else{
            [self moveView:targetView andLayer:targetLayer toPosition:positionArray_[i+inc] animated:YES];
            newTagOfIndex[i+inc] = targetTag;
        }
    }
    //swap solution:
    
    /*if (nearestIndex != currentIndex)
    {
        int targetTag = tagOfIndex_[nearestIndex];
        UIView* targetView = [cardViewArray_ objectAtIndex:targetTag];
        CALayer* targetLayer = [layerArray objectAtIndex:targetTag];
        [self moveView:targetView andLayer:targetLayer toPosition:positionArray_[currentIndex] animated:YES];
        newTagOfIndex[currentIndex] = targetTag;
    }*/
    
    for (i=0; i<cardnum; i++) {
        tagOfIndex_[i] = newTagOfIndex[i];
    }
    
    //finger up
    //TODO: may need to move this part to the begining of this function. depend on the circumstances of last calling of handlePan
    if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled) {
        [self moveView:cardView andLayer:cardLayer toPosition:positionArray_[nearestIndex] animated:YES];
        NSMutableArray* children = [[config childrenOf:currentUUID_] copy];
        for (i=0; i<cardnum; i++) {
            int targetTag = tagOfIndex_[i];
            if (tagOfIndex_[i] == i)
                continue;
            NSObject* child;
            if (targetTag < [children count])
            {
                child = [children objectAtIndex:targetTag];
                if (child == [NSNull null]) {
                    child = nil;
                }
            }
            else{
                child = nil;
            }
            [config updateChildOfNode:currentUUID_ with:(NSString*)child atIndex:i];
        }
        
        //swap is quicker, but refresh is safer
        [self refreshView:currentUUID_];
        /*for (i=0; i<cardnum; i++) {
            tagOfIndex_[i] = i;
            isBlankAtTag_[i] = newIsBlankAtTag[i];
        }*/
        
    }
}

@end