//
//  ViewController.h
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/08.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseManage.h"
//#import "ArticleCell.h"
#import "BackgroundView.h"

#import "Mecab.h"
#import "Node.h"

@interface ViewController : UIViewController{
    Mecab *mecab;
}

@property (nonatomic) Mecab *mecab;
@end
