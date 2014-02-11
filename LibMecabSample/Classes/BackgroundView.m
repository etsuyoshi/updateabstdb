//
//  BackgroundView.m
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/10.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//
//端末画面横サイズ
#define WIDTHDEVICE [UIScreen mainScreen].bounds.size.width
//端末画面縦サイズ
#define HEIGHTDEVICE [UIScreen mainScreen].bounds.size.height
//画面がスライドするフリック幅の閾値
#define THREASHOLDONFLICK 100

#import "BackgroundView.h"



@implementation BackgroundView
@synthesize arrTable = _arrTable;
CGPoint pntStartDrag;//drag開始点
int noStatus;//表示されている画面ID(左から0,1,...,[arrStrBackground count])
int numOfImage;//画像の枚数

NSMutableDictionary *dictBackground;

int widthTable;
int heightTable;

//ArticleTable *leftTable;
//ArticleTable *rightTable;
//ArticleTable *centerTable;

- (id)initWithTable:(NSArray *)_arrTableArg{
    
    widthTable = ((ArticleTable *)_arrTableArg[0]).bounds.size.width;
    heightTable = ((ArticleTable *)_arrTableArg[0]).bounds.size.height;
    
//    NSArray *arrStrBackground = [dictBackground allValues];
    NSMutableArray *arrStrBackground = [NSMutableArray array];
    
    self.arrTable = [NSMutableArray array];
    dictBackground = [NSMutableDictionary dictionary];
    for(int i =0 ; i < [_arrTableArg count];i++){
        //自クラスのarrTableに格納
        [self.arrTable addObject:_arrTableArg[i]];
        
        //画像に対応(辞書dictBackgroundと配列arrStrBackground)
        switch(((ArticleTable *)_arrTableArg[i]).tableType){
            case TableTypeArts:{
                [dictBackground
                 setObject:@"light.png"
                 forKey:[NSNumber numberWithInteger:TableTypeArts]];
                [arrStrBackground addObject:@"light.png"];
                break;
            }
            case TableTypeBlog:{
                [dictBackground
                 setObject:@"desk.png"
                 forKey:[NSNumber numberWithInteger:TableTypeBlog]];
                
                [arrStrBackground addObject:@"desk.png"];
                break;
            }
            case TableTypeBusiness:{
                [dictBackground
                 setObject:@"building.png"
                 forKey:[NSNumber numberWithInteger:TableTypeBusiness]];
                [arrStrBackground addObject:@"building.png"];
                break;
            }
            case TableTypeEntertainment:{
                [dictBackground
                 setObject:@"street.png"
                 forKey:[NSNumber numberWithInteger:TableTypeEntertainment]];
                [arrStrBackground addObject:@"street.png"];
                break;
            }
            case TableTypeFinance:{
                [dictBackground
                 setObject:@"aman.png"
                 forKey:[NSNumber numberWithInteger:TableTypeFinance]];
                [arrStrBackground addObject:@"aman.png"];
                break;
            }
            case TableTypeMatome:{
                [dictBackground
                 setObject:@"wood.png"
                 forKey:[NSNumber numberWithInteger:TableTypeMatome]];
                [arrStrBackground addObject:@"wood.png"];
                break;
            }
            case TableTypePolitics:{
                [dictBackground
                 setObject:@"sunset.png"
                 forKey:[NSNumber numberWithInteger:TableTypePolitics]];
                [arrStrBackground addObject:@"sunset.png"];
                break;
            }
            case TableTypeSports:{
                [dictBackground
                 setObject:@"bird.png"
                 forKey:[NSNumber numberWithInteger:TableTypeSports]];
                [arrStrBackground addObject:@"bird.png"];
                break;
            }
            case TableTypeTechnology:{
                [dictBackground
                 setObject:@"building2.png"
                 forKey:[NSNumber numberWithInteger:TableTypeTechnology]];
                [arrStrBackground addObject:@"building2.png"];
                break;
            }
            default:{
                break;
            }
        }
        
    }
    
//    dictBackground =
//    [NSMutableDictionary dictionaryWithObjectsAndKeys:
//     @"aman.png", [NSNumber numberWithInteger:TableTypeSports],
//     @"bird.png", [NSNumber numberWithInteger:TableTypeTechnology],
//     @"building.png", [NSNumber numberWithInteger:TableTypeArts ],
//     @"desk.png", [NSNumber numberWithInteger:TableTypeBusiness],
////     @"light.png", [NSNumber numberWithInteger:TableTypeFinance],
//     @"street.png", [NSNumber numberWithInteger:TableTypeMatome],
//     @"sunset.png", [NSNumber numberWithInteger:TableTypePolitics],
//     @"wood.png",[NSNumber numberWithInteger:TableTypeBlog],
//     @"building2.png", [NSNumber numberWithInteger:TableTypeEntertainment],
//     nil];
    
//    NSArray *arrStrBackground =
//    [NSArray arrayWithObjects:
//     @"aman.png",
//     @"bird.png",
//     @"building.png",
//     @"building2.png",
//     @"desk.png",
//     @"light.png",
//     @"street.png",
//     @"sunset.png",
//     @"wood.png",
//     nil];
    
    
    
    int _width = [[UIScreen mainScreen] bounds].size.width;
    int _height = [[UIScreen mainScreen] bounds].size.height;
    
    
    //背景オブジェクト
    self = [super initWithFrame:
     CGRectMake(0, 0, _width * [arrStrBackground count], _height)];
//    numOfImage = self.bounds.size.width / [UIScreen mainScreen].bounds.size.width;
    numOfImage = (int)[arrStrBackground count];
    
    if (self) {
        // Initialization code
        @autoreleasepool {
            //ジェスチャー追加
            UIPanGestureRecognizer *panGesture;
            panGesture = [[UIPanGestureRecognizer alloc]
                          initWithTarget:self
                          action:@selector(onFlickedFrame:)];
            [self addGestureRecognizer:panGesture];
            self.userInteractionEnabled = YES;
            
            
            //個別画像
            UIImageView *imvTmp;
//
            //個別背景画像
            for(int i = 0;i < [arrStrBackground count];i++){
                imvTmp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:arrStrBackground[i]]];
                imvTmp.frame = CGRectMake(i * _width, 0, _width, _height);
                //            [arrImvBackground addObject:imvTmp];
                [self addSubview:imvTmp];
            }
            
            //初期状態ではゼロのみ画面に表示:他のarrTable要素はタッチした瞬間に配置される
            ((ArticleTable *)self.arrTable[0]).center = CGPointMake(WIDTHDEVICE/2, HEIGHTDEVICE/2);
            for(int i = 1;i < [self.arrTable count];i++){
                ((ArticleTable *)self.arrTable[i]).frame =
                CGRectMake(WIDTHDEVICE, 0,
                           ((ArticleTable *)self.arrTable[i]).bounds.size.width,
                           ((ArticleTable *)self.arrTable[i]).bounds.size.height);
            }
            
            for(int i = 0;i < [self.arrTable count];i++){
                [self addSubview:((ArticleTable *)self.arrTable[i])];
            }
            
            
        }//autoreleasepool
        
    }
    return self;
}

//スライドした後に実行される
-(void)animateTableToCorrectLocation{
    
    
    [UIView
     animateWithDuration:0.25f
     delay:0
     options:UIViewAnimationOptionCurveEaseIn
     animations:^{
         
         //center
         ((ArticleTable *)self.arrTable[noStatus]).center =
         CGPointMake(noStatus * WIDTHDEVICE + WIDTHDEVICE/2,
                     heightTable/2);
//         centerTable.center =
//         CGPointMake(WIDTHDEVICE/2,
//                     HEIGHTDEVICE/2);
         //左側のテーブル
         for(int i = 0;i < noStatus;i++){
             ((ArticleTable *)self.arrTable[i]).center =
             CGPointMake(noStatus * WIDTHDEVICE - widthTable/2,
                         heightTable/2);
         }
         //右側のテーブル
         for(int i = noStatus+1;i < [dictBackground count];i++){
             ((ArticleTable *)self.arrTable[i]).center =
             CGPointMake((noStatus+1) * WIDTHDEVICE + widthTable/2,
                         heightTable/2);
         }
     }
     completion:^(BOOL finished){
         if(finished){
             NSLog(@"table animate complete");
         }
     }];
}

-(NSMutableArray *)getArray{
    return self.arrTable;
}

//常に定位置にいるように設定
-(void)onFlickedFrame:(UIPanGestureRecognizer *)gr{
    
    //移動幅:コンマ数秒間隔でサンプリングされた際の移動幅(タッチしてからの移動幅ではない)
    CGPoint movingPoint = [gr translationInView:self];
    //移動後の背景中心位置
    CGPoint movedPoint = CGPointMake(self.center.x + movingPoint.x,
                                     self.center.y);
    
    //背景画像の移動:直接移動
    self.center = movedPoint;
    
    //現在見えている中央のテーブルとその両サイドのテーブルのみ移動:半分移動
    //中央のテーブル
    ((ArticleTable *)self.arrTable[noStatus]).center =
    CGPointMake(((ArticleTable *)self.arrTable[noStatus]).center.x - movingPoint.x/2,
                ((ArticleTable *)self.arrTable[noStatus]).center.y);
    
    
    //左隣を画面上に表示
    if(noStatus != 0){
        ((ArticleTable *)self.arrTable[noStatus-1]).center =
        CGPointMake(((ArticleTable *)self.arrTable[noStatus-1]).center.x - movingPoint.x/2,
                    ((ArticleTable *)self.arrTable[noStatus-1]).center.y);
    }
    
    //右隣を画面上に表示
    if(noStatus != [dictBackground count]-1){
        ((ArticleTable *)self.arrTable[noStatus+1]).center =
        CGPointMake(((ArticleTable *)self.arrTable[noStatus+1]).center.x - movingPoint.x/2,
                    ((ArticleTable *)self.arrTable[noStatus+1]).center.y);
    }
    
    
    
    //それ(両サイド)以外のテーブル
    //左側のテーブル
    for(int i = 0;i < noStatus-1;i++){
        ((ArticleTable *)self.arrTable[i]).center =
        CGPointMake((noStatus-1) * WIDTHDEVICE - widthTable/2,
                    heightTable/2);
    }
    //右側のテーブル
    for(int i = noStatus+2;i < [dictBackground count];i++){
        ((ArticleTable *)self.arrTable[i]).center =
        CGPointMake((i+1) * WIDTHDEVICE + widthTable/2,
                    heightTable/2);
    }
    
    [gr setTranslation:CGPointZero inView:self];
    
    
    
    if (gr.state == UIGestureRecognizerStateBegan) {
        
        //ドラッグ開始点の設定
        pntStartDrag = CGPointMake(self.center.x,
                                   self.center.y);
        //現在位置の判定
        int xOfRightImageCenter = self.frame.origin.x + self.bounds.size.width - WIDTHDEVICE/2;//一番右の画像の中心位置
        for(int i = 0;i < numOfImage;i++){
            if(xOfRightImageCenter >= i * WIDTHDEVICE &&
               xOfRightImageCenter < (i + 1) * WIDTHDEVICE){
                //左の画像(の中心)が見えている状態を０、右隣の画像(中心)が画面上に見えている場合は１、。。。
                noStatus = numOfImage - i - 1;
            }
        }
    }else if (gr.state == UIGestureRecognizerStateChanged) {//移動中
    }
    // 指が離されたとき、ビューを元に位置に戻して、ラベルの文字列を変更する
    else if (gr.state == UIGestureRecognizerStateEnded) {//指を離した時
        
        
        if(pntStartDrag.x - self.center.x > THREASHOLDONFLICK){//左にドラッグ
            if(noStatus < numOfImage-1)noStatus++;
        }else if(pntStartDrag.x - self.center.x < -THREASHOLDONFLICK){//右にドラッグ
            if(noStatus > 0)noStatus--;
        }else{
            //do nothing
        }
        NSLog(@"to status = %d", noStatus);
        [UIView
         animateWithDuration:0.25f
         delay:0.0f
         options:UIViewAnimationOptionCurveEaseIn
         animations:^{
             
             self.frame =
             CGRectMake(WIDTHDEVICE * -noStatus, 0, self.bounds.size.width,
                        self.bounds.size.height);
             NSLog(@"animated to x=%f", WIDTHDEVICE * - noStatus);
         }
         completion:^(BOOL finished){
             if(finished){
                 //更新されたnoStatusを反映したテーブルの位置、もしくはフリックでズレたテーブルの位置を正しい位置に配置
                 [self animateTableToCorrectLocation];
                 
             }
         }];
    }
}


@end



