//
//  ArticleTable.m
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/10.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//

#import "ArticleTable.h"

@implementation ArticleTable

@synthesize tableType = _tableType;
@synthesize cellColor = _cellColor;
@synthesize arrCells = _arrCells;


int intervalCell;
int widthCell;
int heightCell;

-(id)initWithType:(TableType)tableType{
    //縦スクロールする場合は以下の長さを変更する
    self = [super initWithFrame:CGRectMake(0, 0,
                                           [UIScreen mainScreen].bounds.size.width*.9,
                                           [UIScreen mainScreen].bounds.size.height)];
    
    if(self){
        self.tableType = tableType;
        [self initializer];
    }
    
    return self;
}

-(void)initializer{
    
    //prohibit to let component allocated upon this be transparancy
//    self.alpha = 0.0f;
    
    
    //テーブル毎にセルの色を変更
//    UIColor *tableColor;
    switch (self.tableType) {
            
        case TableTypeSports:{
            self.cellColor = [UIColor redColor];
//            tableColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3f];//test:red
            break;
        }
        case TableTypeTechnology:{
            self.cellColor = [UIColor greenColor];
//            tableColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3f];//test:green
            break;
        }
        case TableTypeArts:{
            self.cellColor = [UIColor blueColor];
//            tableColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.3f];//test:blue
            break;
        }
        case TableTypeBusiness:{
            self.cellColor = [UIColor purpleColor];
//            tableColor = [UIColor colorWithRed:1 green:0 blue:1 alpha:0.3f];//test:purple
            break;
        }
        case TableTypeFinance:{
            self.cellColor = [UIColor yellowColor];
            break;
        }
        case TableTypeBlog:{
            self.cellColor = [UIColor brownColor];
            break;
        }
        case TableTypeEntertainment:{
            self.cellColor = [UIColor cyanColor];
            break;
        }
        case TableTypeMatome:{
            self.cellColor = [UIColor magentaColor];
            break;
        }
        case TableTypePolitics:{
            self.cellColor = [UIColor darkGrayColor];
            break;
        }
        default:
            break;
    }
    
    //test:color
//    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.3f];
    self.backgroundColor = [UIColor clearColor];
    
    
    self.arrCells = [NSMutableArray array];
    
    
//    ArticleCell *articleCell = [[ArticleCell alloc]initWithFrame:
//                                CGRectMake(10, 10, 250, 100)];
//    articleCell.translucentTintColor = cellColor;
//    articleCell.center = CGPointMake(self.bounds.size.width/2,
//                                     150);
//    [self addSubview:articleCell];
}

-(void)addCell:(ArticleCell *)articleCell{
    articleCell.translucentTintColor = self.cellColor;
    [self.arrCells addObject:articleCell];
    heightCell = articleCell.bounds.size.height;
    widthCell = articleCell.bounds.size.width;
    intervalCell = 10;
    
    
    articleCell.frame =
    CGRectMake(10, [self.arrCells count] * (intervalCell + heightCell),
               widthCell, heightCell);
    [self addSubview:[self.arrCells lastObject]];
    
    /*あとやるべきこと
     *セルにリスナーを付けて別画面を起動し、要約文を表示
     *tableを縦にスクロールできるようにする
     */
}

@end
