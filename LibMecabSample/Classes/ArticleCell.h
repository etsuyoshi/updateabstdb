//
//  ArticleTile.h
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/08.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//
//ILTranslucentView : https://github.com/ivoleko/ILTranslucentView
#import "ILTranslucentView.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ArticleData.h"

@interface ArticleCell : ILTranslucentView
//@property (nonatomic, copy) UIImageView *imv;
//@property (nonatomic) NSString *strTitle;
//@property (nonatomic, copy) NSString *text;
@property (nonatomic) ArticleData *articleData;
//-(id)initWithFrame:(CGRect)frame withText:(NSString *)_textArg;
-(id)initWithFrame:(CGRect)frame withArticleData:(ArticleData *)articleData;
@end
