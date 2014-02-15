//
//  ArticleTile.m
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/08.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//

#import "ArticleCell.h"

@implementation ArticleCell
@synthesize text = _text;
//@synthesize imv = _imv;


-(id)initWithFrame:(CGRect)frame{
    
    return [self initWithFrame:frame
                      withText:(NSString *)_text];
}
-(id)initWithFrame:(CGRect)frame withText:(NSString *)_textArg{
    self = [super initWithFrame:frame];
    
    self.text = _textArg;
    
    
    if(self){
        [self initializer];
        
        UITapGestureRecognizer *tapGesture;
        tapGesture = [[UITapGestureRecognizer alloc]
                      initWithTarget:self
                      action:@selector(onTapped:)];
        [self addGestureRecognizer:tapGesture];
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

-(void)initializer{
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
        uil.text = self.text;
        
        
        [self addSubview:uil];
    }
}

-(void)onTapped:(UITapGestureRecognizer *)gr{
    NSLog(@"ontapped");
}


@end
