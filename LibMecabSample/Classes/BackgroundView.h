//
//  BackgroundView.h
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/10.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//

#import "ArticleTable.h"
#import <UIKit/UIKit.h>

@interface BackgroundView : UIImageView


@property (nonatomic) NSMutableArray *arrTable;
- (id)initWithTable:(NSArray *)_arrTableArg;
@end
