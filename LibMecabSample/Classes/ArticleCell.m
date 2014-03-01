//
//  ArticleTile.m
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/08.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//

#import "ArticleCell.h"
#import "TextViewController.h"

@implementation ArticleCell
//@synthesize strTitle;
//@synthesize text = _text;
@synthesize articleData;
//@synthesize imv = _imv;


//-(id)initWithFrame:(CGRect)frame{
//    
//    return [self initWithFrame:frame
//                      withText:(NSString *)_text];
//}
//-(id)initWithFrame:(CGRect)frame withText:(NSString *)_textArg{
//    self = [super initWithFrame:frame];
//    NSLog(@"text=%@", _textArg);
//    
//    
//    
//    if(self){
//        [self initializerWithText:_textArg];
//        self.text = _textArg;
//        
//    }
//    
//    return self;
//}

-(id)initWithFrame:(CGRect)frame
   withArticleData:(ArticleData *)_articleData{
    self = [super initWithFrame:frame];
    self.articleData = _articleData;
    NSLog(@"ArticleCell initWithArticleData : %@",
          self.articleData.title);
    
    if(self){
        [self initializerWithText:self.articleData];

        
    }
    
    return self;
}



-(void)initializerWithText:(ArticleData *)_articleData{
    @autoreleasepool {
        //デフォルト値：インスタンス化した後も設定可能
        self.translucentAlpha = 0.8f;
        self.translucentStyle = UIBarStyleDefault;
        self.translucentTintColor = [UIColor yellowColor];
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *uil = [[UILabel alloc] init];
        uil.frame = self.bounds;
        uil.backgroundColor = [UIColor clearColor];
        uil.textColor = [UIColor blueColor];
        uil.font = [UIFont fontWithName:@"AppleGothic" size:12];
        uil.textAlignment = NSTextAlignmentCenter;
        uil.text = _articleData.title;
        uil.numberOfLines = 5;
//        NSLog(@"text=%@", _strText);
        [self addSubview:uil];
    }
}



@end
