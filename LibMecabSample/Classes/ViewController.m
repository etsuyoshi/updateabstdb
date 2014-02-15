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

@synthesize mecab;

BackgroundView *backgroundView;
CGPoint pntStartDrag;
int noStatus;//現在の状態(どの区切りか)を判別:最初は一番左の状態

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.mecab = [Mecab new];
    
    
    
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
    NSDictionary *dictTmp = [DatabaseManage getValueFromDBAt:3];
    NSString *strReturnBody = [dictTmp objectForKey:@"body"];
    NSLog(@"strTmp = %@", strReturnBody);
    
    TextAnalysis *textAnalysis = [[TextAnalysis alloc]initWithText:strReturnBody];
    NSArray *arrImportantSentence = textAnalysis.getImportantSentence;
    NSArray *arrImportantNode = textAnalysis.getImportantNode;
    
    
    //test
//    for(int i =0;i < [arrImportantNode count];i++){
//        NSLog(@"arrNode%d＝%@", i, arrImportantNode[i]);
//    }
//    for(int i =0;i < [arrImportantSentence count];i++){
//        NSLog(@"arrSentence%d=%@",i, arrImportantSentence[i]);
//    }
    
    
    //test
    //stringを句点(。)で分割して文章に分割
//    NSArray *arrSentence = [NSArray array];//空配列
//    NSCharacterSet *spr = [NSCharacterSet characterSetWithCharactersInString:@"\n。"];//複数文字列を指定
//    arrSentence = [strReturnBody componentsSeparatedByCharactersInSet:spr];
//    //以下トークン分割はcomponentsSeparatedByCharactersInSet:で複数指定可能
////    arrSentence = [strReturnBody componentsSeparatedByString:@"。"];//句点で分割
//    
//    //参考：「」で囲われてる文字列は。で区切らない方が良い。むしろ、鍵カッコを区切り文字として、中の文章は一つのとして扱う
//    for(int i = 0;i < [arrSentence count];i++){
//        NSLog(@"sentence%d=%@", i, arrSentence[i]);
//    }
//    
//    //mecabによる形態素解析
//    NSArray *arrayNodes = [mecab parseToNodeWithString:arrSentence[0]];//テキストをメカブで形態素解析してnodes(UITableCell)に格納
//    for(int i = 0 ;i < [arrayNodes count];i++){
//        Node *node = arrayNodes[i];
//        NSLog(@"%@ : 品詞=%@", node.surface, node.partOfSpeech);
//    }
    
    
    
//	Node *node = [nodes objectAtIndex:indexPath.row];
//	cell.surfaceLabel.text = node.surface;
//	cell.featureLabel.text = [node partOfSpeech];//[node pronunciation];
    
    
    
    
    //表示コンポーネントやデータの初期化等
    NSArray *arrTable = [NSArray arrayWithObjects:
                         [[ArticleTable alloc] initWithType:TableTypeTechnology],
                         [[ArticleTable alloc] initWithType:TableTypeSports],
                         [[ArticleTable alloc] initWithType:TableTypeArts],
                         [[ArticleTable alloc] initWithType:TableTypeBusiness],
                         [[ArticleTable alloc] initWithType:TableTypeFinance],
                         nil];
    
    for(int i = 0 ;i < [arrTable count];i++){//全てのテーブルに対して
        for(int j = 0;j < 5;j++){//各テーブルに５個のセルを配置
            
            //記事セル作成
            ArticleCell *articleCell =
            [[ArticleCell alloc]initWithFrame:
             CGRectMake(0, 0, 250, 100)
                                     withText:arrImportantSentence[j]
             ];//位置はaddCellメソッド内で適切に配置
            
            //記事セルにテキストを格納
//            articleCell.text = arrImportantSentence[j];
            
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
