//
//  ViewController.m
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/08.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//

#define DispDatabaseLog

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

BackgroundView *backgroundView;
CGPoint pntStartDrag;
int noStatus;//現在の状態(どの区切りか)を判別:最初は一番左の状態

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
//    for (TFHppleElement *element in tutorialsNodes) {
//        // 5
//        Tutorial *tutorial = [[Tutorial alloc] init];
//        [newTutorials addObject:tutorial];
//        
//        // 6
//        tutorial.title = [[element firstChild] content];
//        
//        // 7
//        tutorial.url = [element objectForKey:@"href"];
//    }
    
    
    
//    @"id",
//    @"datetime",
//    @"blog_id",
//    @"title",
//    @"url",
//    @"body_with_tags",
//    @"body",
//    @"hatebu",
//    @"saveddate",
    
    //上記キー値を元にデータを取得
    NSDictionary *strTmp = [DatabaseManage getValueFromDBAt:1];
    NSLog(@"strTmp = %@", strTmp);
    
    //表示コンポーネントやデータの初期化等
    NSArray *arrTable = [NSArray arrayWithObjects:
                         [[ArticleTable alloc] initWithType:TableTypeTechnology],
                         [[ArticleTable alloc] initWithType:TableTypeSports],
                         [[ArticleTable alloc] initWithType:TableTypeArts],
                         [[ArticleTable alloc] initWithType:TableTypeBusiness],
                         [[ArticleTable alloc] initWithType:TableTypeFinance],
                         nil];
    
    for(int i = 0 ;i < [arrTable count];i++){
        for(int j = 0;j < 5;j++){//各テーブルに５個のセルを配置
            ArticleCell *articleCell =
            [[ArticleCell alloc]initWithFrame:
             CGRectMake(0, 0, 250, 100)];//位置はaddCellメソッド内で適当に配置
            
            [((ArticleTable *)arrTable[i]) addCell:articleCell];
            
//            NSLog(@"arrtable%d = %@", i, arrTable[i]);
        }
    }
    
    
    backgroundView = [[BackgroundView alloc]initWithTable:arrTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
    //backgroundの表示
//    [self.view addSubview:imvBackground];
    [self.view addSubview:backgroundView];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //背景やコンポーネントの配置
    
    
    
    //＜未＞画面サイズに対してマージンが少しある程度のフレームを作成し、
    //フリックで背景画像よりも少し小さめ移動させる
    //コンポーネントの配置
//    ArticleCell *articleView =
//    [[ArticleCell alloc]
//     initWithFrame:
//     CGRectMake(10, 100, 200, 150)];
//    
//    articleView.translucentAlpha = 0.5f;
////    [self.view addSubview:articleView];
//    [backgroundView addSubview:articleView];
}




-(void)getDataFromDB{
    //databasemanageクラスからデータを取得(引数なしだと最大100記事を取得)
    NSArray *array = [DatabaseManage getValueFromDB];//100個取得
    
    NSString *strId = nil;
    NSString *strBody = nil;
    NSString *strSaved = nil;
    NSString *strDate = nil;
    NSDictionary *_dict = nil;
    for(int i = 0;i < [array count];i++){
        _dict = array[i];
        strId = [_dict objectForKey:@"id"];
        strBody = [_dict objectForKey:@"body"];
        strSaved = [_dict objectForKey:@"saveddate"];
        strDate = [_dict objectForKey:@"datetime"];
#ifdef DispDatabaseLog
        NSLog(@"id=%@",strId);
        
        NSLog(@"id=%@",strBody);
        NSLog(@"id=%@",strSaved);
        NSLog(@"id=%@",strDate);
#endif
    }
}


@end
