//
//  ViewController.m
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/08.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//

//#define ABSTRACTION_TEST

#define DispDatabaseLog
#define MaxRecordEveryPage 4




#import "ViewController.h"
#import "TextViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize mecab;

BackgroundView *backgroundView;
CGPoint pntStartDrag;
NSMutableArray *arrArticleData;

UIActivityIndicatorView *indicator;

int noStatus;//現在の状態(どの区切りか)を判別:最初は一番左の状態

-(id)init{
    self = [super init];
    NSLog(@"init from ViewController");
    if(self){
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        //test
//        NSString *str = @"it's";
//        if([str rangeOfString:@"\'"].location != NSNotFound){
//            NSLog(@"シングルクオーテーションが存在しています");
//            NSLog(@"修正前Value = %@", str);
//            //未対応！：なぜか以下でシングルクオーテーションをシングルクオートx２「''」に変換できない！！理由不明！！
//            str = [str stringByReplacingOccurrencesOfString:@"'"
//                                           withString:@"''"];
//            
//            NSLog(@"修正後newValue = %@", str);
//        }
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.mecab = [Mecab new];
    
    //test
//    NSDictionary *dict = [DatabaseManage getRecordFromDBAt:0];
//    NSLog(@"abstforblog=%@", [dict objectForKey:@"abstforblog"]);//nil
//    NSLog(@"ispostblog=%d", [[dict objectForKey:@"ispostblog"] integerValue]);//0
    
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
    
    
    
    
    
    //test
//    NSLog(@"arrNode count=%d, arrSentence count=%d",
//          [arrImportantNode count],
//          [arrImportantSentence count]);
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
    
    
    
    
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    //インディケータを張り付け
    [self.view addSubview:indicator];
    [self.view bringSubviewToFront:indicator];
    
    //取得中のインジケータースタート
    [indicator startAnimating];
    
#ifdef ABSTRACTION_TEST
    
    //test用データによる要約テスト:id=8029でチェック
    
    
    //dbからデータ取得(id=8029)
    int _noID = 8029;
    
    NSDictionary *dictTmp = [DatabaseManage getRecordFromDBAt:_noID];
    NSString *strReturnBody = [dictTmp objectForKey:@"body"];
    NSString *strTitle = [dictTmp objectForKey:@"title"];
    _noID = [[dictTmp objectForKey:@"id"] integerValue];
    NSLog(@"strTmp = %@", strReturnBody);
    
    
    TextAnalysis *textAnalysis = [[TextAnalysis alloc]
                                  initWithText:strReturnBody
                                  withTitle:strTitle];
    NSArray *arrImportantSentence = [textAnalysis getImportantSentence];
    NSArray *arrImportantNode = [textAnalysis getImportantNode];
    
    
    for(int i = 0;i < [arrImportantNode count];i++){
        NSLog(@"arrImpNode[%d]=%@", i, ((Node *)arrImportantNode[i]).surface);
    }
    
    
    for(int i = 0 ;i < [arrImportantSentence count];i++){
        NSLog(@"arrImpSntc[%d]=%@", i, arrImportantSentence[i]);
    }
    
    NSLog(@"abstraction test mode exit@viewDidAppear from ViewController");
    
#else
    
    //やるべきこと
    //画面が表示されるたびにabstforblogに何も入っていないidを取得(DatabaseManage getLastIDFromDBUnder:category:)するようにしたい
    //そのため、以下をviewDidLoadからviewDidAppearに移植した、が、そうしたら画面が黒いままになった
    
    //記事を表示した後、相応しくない場合はDBから削除するメニューを実装する必要！
    
    //表示コンポーネントやデータの初期化等
    NSArray *arrTable = [NSArray arrayWithObjects:
                         [[ArticleTable alloc] initWithType:TableTypeTechnology],
//                         [[ArticleTable alloc] initWithType:TableTypeSports],
//                         [[ArticleTable alloc] initWithType:TableTypeArts],
//                         [[ArticleTable alloc] initWithType:TableTypeBusiness],
//                         [[ArticleTable alloc] initWithType:TableTypeFinance],
                         nil];
    
    //記事データ格納用配列の初期化
    
    int countArticle = 0;
    int category = 0;
    arrArticleData = [NSMutableArray array];//以下のcountArticleと格納した順番が同じになるようにする
    
    
    int _noID = 100000;//最後にアップデートしたIDを格納しておく
    
    for(int i = 0 ;i < [arrTable count];i++){//全てのテーブル(画面)に対して
        _noID = 100000;//最後にアップデートしたIDを格納しておく
        //カテゴリ番号を取得する：ユーザーによって並べ替えられている
        category = i;//i番目ページに対応するカテゴリを取得するように改良すべき(ユーザーによって並べ替えられている)
        
        
        //レコード数の存在可否を判定
        if(category != 0){
            //sqlを発行して指定したカテゴリのレコード数を取得し、レコードが存在すれば以下のjループを回す:未実装
            
            
            continue;//for-i
        }
        
        
        //レコード数が存在していればループが回る:現在カテゴリにおける記事数と最大記事数の小さい方
        int numArticleInCategory = 1;//iによって動的に取得出来るようにする：未実装
        for(int j = 0;j < MIN(numArticleInCategory, MaxRecordEveryPage);j++){//各テーブルにセルを配置
            
            
            //ループで新しい記事から_noIDを取得していく:取得出来なかった場合はnilを返すので判別できるようにNSNumber型にしておく
            
//            NSNumber *_noIDNumber =
//            [NSNumber numberWithInt:
//             [DatabaseManage
//             getLastIDFromDBUnder:_noID
//             category:category]];
            NSString *_noIDNumber =
            [DatabaseManage
             getLastIDFromDBUnder:_noID
             category:category];
            
            //テスト
//            NSNumber *_noIDNumber =
//            [NSNumber numberWithInteger:14227];
            NSLog(@"_noIDNumber = %@", _noIDNumber);
            
            if(_noIDNumber== nil ||
               [_noIDNumber isEqual:[NSNull null]]){
                
                NSLog(@"idが取得出来ませんでした。再取得します。");
                j--;//ループ継続のため
                continue;
            }else{//何らかのidが文字列として取得できた場合(文字列から数値への変換が可能かどうかの判定は未実施)
                _noID = [_noIDNumber intValue];
//                NSLog(@"取得したidは%d", _noID);
            }
            //    @"id",
            //    @"datetime",
            //    @"blog_id",
            //    @"title",
            //    @"url",
            //    @"body_with_tags",
            //    @"body",
            //    @"hatebu",
            //    @"saveddate",
            //    @"abstforblog",
            //    @"ispostblog",
            
            
            //上記キー値を元にデータを取得
            NSDictionary *dictTmp = [DatabaseManage getRecordFromDBAt:_noID];
            NSString *strReturnBody = [dictTmp objectForKey:@"body"];//シングルクオートやダブルクオートがある場合は誤動作回避のため置換されている前提
            NSString *strTitle = [dictTmp objectForKey:@"title"];
            _noID = (int)[[dictTmp objectForKey:@"id"] integerValue];
            NSLog(@"strTmp = %@", strReturnBody);
            
            //http://qiita.com/yimajo/items/c9338a715016e7a812b1
            //            NSLog(@"abstforblog=%@", [dictTmp objectForKey:@"abstforblog"]);
            //            NSLog(@"ispostblog=%@", [dictTmp objectForKey:@"ispostblog"]);
            //            if([[dictTmp objectForKey:@"abstforblog"] isEqualToString:@"(null)"]){
            //                NSLog(@"string");
            //            }else if([dictTmp objectForKey:@"abstforblog"] == [NSNull null]){
            //                NSLog(@"null");
            //            }else if([[dictTmp objectForKey:@"abstforblog"] isEqualToString:@""]){
            //                NSLog(@"blank");
            //            }else if([dictTmp objectForKey:@"abstforblog"] == nil){
            //                NSLog(@"nil");
            //            }else{
            //                NSLog(@"other");
            //            }
            
            
            TextAnalysis *textAnalysis = [[TextAnalysis alloc]
                                          initWithText:strReturnBody
                                          withTitle:strTitle];
            NSArray *arrImportantSentence = [textAnalysis getImportantSentence];
            NSArray *arrImportantNode = [textAnalysis getImportantNode];
            
            //要約文章結合：temporary=>本来はタイトルと最重要な要約文章のみ表示して、クリックしたら別の要約文章全体を見せるようにしたい！！！
            //            NSString *strAbstract = @"";
            //            for(int noSen = 0;noSen < MIN([arrImportantSentence count],2);noSen++){
            //                strAbstract = [NSString stringWithFormat:@"%@%@",
            //                               strAbstract, arrImportantSentence[noSen]];
            //            }
            //
            //            NSString *strKeyword = @"";
            //            for(int noWord = 0;noWord < MIN([arrImportantNode count],4);noWord++){
            //                strKeyword = [NSString stringWithFormat:@"%@%@",
            //                              strKeyword,
            //                              ((Node *)arrImportantNode[noWord]).surface];
            //            }
            
            ArticleData *articleData = [[ArticleData alloc]init];
            articleData.noID = _noID;
            articleData.title = strTitle;
            articleData.text = strReturnBody;
            articleData.arrImportantNode = arrImportantNode;
            articleData.arrImportantSentence = arrImportantSentence;
            
            //全ての記事データ(articleData)を配列に格納して、タップされた時に参照出来るようにする
            [arrArticleData addObject:articleData];
            
            
            //記事セル作成
            ArticleCell *articleCell =
            [[ArticleCell alloc]
             initWithFrame:CGRectMake(0, 0, 250, 100)//別の場所で指定するので位置情報に意味はない
             withArticleData:articleData
             ];//位置はaddCellメソッド内で適切に配置
            
            UITapGestureRecognizer *tapGesture;
            tapGesture = [[UITapGestureRecognizer alloc]
                          initWithTarget:self
                          action:@selector(onTapped:)];
            [articleCell addGestureRecognizer:tapGesture];
            articleCell.userInteractionEnabled = YES;
            articleCell.tag=countArticle;//初期番号をゼロにするため
            
            NSLog(@"tag=%d", countArticle);
            
            //記事セルにテキストを格納
            //            articleCell.text = arrImportantSentence[j];
            
            [((ArticleTable *)arrTable[i]) addCell:articleCell];
            
            //            NSLog(@"arrtable%d = %@", i, arrTable[i]);
            
            countArticle++;
        }
    }
    //インジケータを止める
    [indicator stopAnimating];
    
    
    //一時しのぎ：本来ならばテキストだけ変えるとか,articleCellのみ変えるとかすべき
    [backgroundView removeFromSuperview];
    
    backgroundView = [[BackgroundView alloc]initWithTable:arrTable];
    
    //backgroundの表示
    [self.view addSubview:backgroundView];
    
    
    //要約文チェック(テスト)モードなら自動更新せずに記事セルをタップして実行させるビューを連続して自動で実行させる
    [self dispNextViewController:0];//TextViewControllerを表示
#endif//#IFNDEF ABSTRACTION_TEST
    
}


-(void)onTapped:(UITapGestureRecognizer *)gr{
    NSLog(@"ontapped");
    int noTapped = [(UIGestureRecognizer *)gr view].tag;
    NSLog(@"%d",[(UIGestureRecognizer *)gr view].tag);
    
    //呼出し元viewcontrollerで以下を実行
    
//    ArticleData *articleData = [[ArticleData alloc]init];
//    articleData.text = @"text";
//    articleData.title = @"title";
    
    [self dispNextViewController:noTapped];
}

-(void)dispNextViewController:(int)noTapped{
    NSLog(@"dispNextViewController from ViewController");
    TextViewController *tvcon =
    [[TextViewController alloc]
     initWithArticle:(ArticleData *)arrArticleData[noTapped]];
    [self presentViewController:tvcon animated:NO completion:nil];
}


-(void)getDataFromDB{
    //databasemanageクラスからデータを取得(引数なしだと最大100記事を取得)
    NSArray *array = [DatabaseManage getRecordFromDBAll];//100個取得
    
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
