//
//  TextViewController.m
//  UpdateAbstDB
//
//  Created by 遠藤 豪 on 2014/02/26.
//
//

#import "TextViewController.h"

@interface TextViewController ()

@end

@implementation TextViewController

@synthesize idNo;
@synthesize strTitle;
@synthesize strText;
@synthesize strKeyword;

UIButton *returnButton;//戻る
UIButton *uploadButton;//ブログへアップロードする

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithArticle:(ArticleData *)articleData{
    self = [super init];
    if(self){
        
        self.idNo = articleData.noID;
        self.strTitle = articleData.title;
        
        
        NSArray *_arrRandomWord =
        [NSArray arrayWithObjects:
         @"マシン",@"学習",@"なぜ",@"明日",@"車",@"女性",@"暴動",@"私",@"天気",@"地下鉄",@"カフェ",
         @"中学生",@"高校生",@"大学生",@"小学生",@"キーワード",@"まさか",@"傘",@"雨",@"ベンツ",@"六本木",
         @"男性",@"テレビ",@"フェラーリ",@"まつたけ",@"ステーキ",@"渋谷",@"表参道",@"青山一丁目",@"新宿",
         @"東京",@"外苑前",@"後",@"性別",@"神田",@"浜松町",@"池尻大橋",@"鴬谷",@"上智",@"大学",@"ミシシッピ",
         @"連結",@"ニューロン",@"バックプロップ",@"英語",@"運動",@"遠足",@"散歩",
         @"wifi",@"うぃふぃ",@"ウィフィ",@"ルータ",@"ルーター",@"端末",@"機械",@"装置",
         @"モバイル",@"ポケット",@"wimax",@"biglobe",@"emobile",
         nil];
        
        
        NSArray *arrCombine =
        [NSArray arrayWithObjects:
         @"を",@"に",@"は",@"と",@"も",@"が",@"ら",@"か",@"の",@"で",@"より",@"から",@"にて",@"へ",
         @"。",@"。",@"。",@"。",@"、",@"、",@"、",@"、",//なるべく多くの句読点を入れる
         nil];
        
        
        //重要文章の設定
        NSString *_strText = @"";
        if([articleData.arrImportantSentence count] > 0){
            _strText = articleData.arrImportantSentence[0];//temporary
        }else{
            _strText = _arrRandomWord[arc4random() % [_arrRandomWord count]];
        }
        for(int i = 1;i < [articleData.arrImportantSentence count];i++){
            _strText = [NSString stringWithFormat:
                        @"%@,%@",_strText,articleData.arrImportantSentence[i]];
        }
        
        self.strText = _strText;
        
        
        
        //重要語の定義=>ブログにアップするテキストとする
        //方法：キーワードを格助詞で連結＆要所要所(最初と途中の一部)に本文を配置
        
        //最初は文章が存在すればその文章を格納、なければランダムな単語を格納
        NSString *_strKeyword = @"";
        if([articleData.arrImportantSentence count] > 0){
            
            _strKeyword = articleData.arrImportantSentence[0];//temporary
        }else{
            _strKeyword = _arrRandomWord[arc4random() % [_arrRandomWord count]];
        }
        
        
        
        //被リンクを張る
        _strKeyword = [NSString stringWithFormat:
                       @"%@%@",
                       _strKeyword,
                       //<a href="
                       @"<BR><a href=\"http://xn--wifi-to4c3j9d.jp\">wifiルータ.jp</a><BR>"];
        
        //その後に重要文章を一つだけ配置(文章が存在すれば)
        if([articleData.arrImportantSentence count] > 0){
            int _no = arc4random() % [articleData.arrImportantSentence count];
            
            _strKeyword = [NSString stringWithFormat:
                           @"%@,%@",
                           _strKeyword,
                           articleData.arrImportantSentence[_no]];
        }
        
        
        //その後に重要語をランダムな順番で連結
        for(int i = 1;i < [articleData.arrImportantNode count];i++){
            _strKeyword = [NSString stringWithFormat:
                           @"%@%@%@",
                           _strKeyword,
                           arrCombine[arc4random() % [arrCombine count]],
                           ((Node *)articleData.arrImportantNode[i]).surface];
        }
        //重要語にランダムな単語を与える
        for(int i = 0;i < 300;i ++){
            _strKeyword = [NSString stringWithFormat:
                           @"%@%@%@",
                           _strKeyword,
                           arrCombine[arc4random() % [arrCombine count]],
                           _arrRandomWord[arc4random() % [_arrRandomWord count]]];
        }
        
        
        self.strKeyword = _strKeyword;
        
        NSLog(@"strTitle=%@", self.strTitle);
        NSLog(@"strText=%@", self.strText);
        NSLog(@"strKeyword=%@", self.strKeyword);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    //タイトル
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, 50)];
    lblTitle.text = self.strTitle;
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:.5f];
    lblTitle.numberOfLines = 1;
    [self.view addSubview:lblTitle];
    
    //本文
    UILabel *lblText=[[UILabel alloc]initWithFrame:CGRectMake(0, lblTitle.frame.origin.y + lblTitle.bounds.size.height,
                                                              self.view.bounds.size.width, 200)];
    lblText.text = self.strText;
    lblText.textColor = [UIColor blackColor];
    lblText.backgroundColor=[UIColor colorWithRed:0 green:1.0f blue:0 alpha:0.5f];//[UIColor clearColor];
    lblText.numberOfLines = 0;
    [self.view addSubview:lblText];
    
    
    //キーワード
    UILabel *lblKeyword=[[UILabel alloc]initWithFrame:CGRectMake(0, lblText.frame.origin.y + lblText.bounds.size.height,
                                                              self.view.bounds.size.width, 300)];
    lblKeyword.text = self.strKeyword;
    lblKeyword.textColor = [UIColor blackColor];
    lblKeyword.backgroundColor=[UIColor colorWithRed:0 green:0 blue:1.0f alpha:0.5f];//[UIColor clearColor];
    lblKeyword.numberOfLines = 0;
    [self.view addSubview:lblKeyword];
    
    
    returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [returnButton setBackgroundColor:[UIColor redColor]];
    returnButton.frame = CGRectMake(10, 10, 100, 60);//
    
    [returnButton addTarget:self
                     action:@selector(onTappedReturnButton:)
           forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:returnButton];
    
    
    
    uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [uploadButton setBackgroundColor:[UIColor blueColor]];
    uploadButton.frame = CGRectMake(250, 10, 100, 60);
    
    [uploadButton addTarget:self
                     action:@selector(onTappedUploadButton:)
           forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:uploadButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)onTappedReturnButton:(UIButton *)button{
    
    [self dismissViewControllerAnimated:NO completion:nil];//itemSelectVCのpresentViewControllerからの場合
}

-(void)onTappedUploadButton:(UIButton *)button{
    //ダイアログ表示:yesの時に別メソッド実行して、アップロード用phpファイルを実行(このphpファイルによってdbが更新される)
//    dialog
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:@"更新しますか"
     message:@"更新する場合は「はい」を選択して下さい"
     delegate:self
     cancelButtonTitle:@"いいえ"
     otherButtonTitles:@"はい",
     nil];
    [alert show];
    
}

//-(void)onExecuteUpload{
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:{//更新キャンセル
            //１番目のボタンが押されたときの処理を記述する
            break;
        }
        case 1:{//更新実行
            //２番目のボタンが押されたときの処理を記述する
            
            //抽出文章に重要キーワードを格納＝最終的にこれがブログにアップされるのでもう少し改良して文章になれるようにする
            [DatabaseManage
             updateValueToDB:[NSString stringWithFormat:@"%d",self.idNo]
             column:@"abstforblog"
             newVal:self.strKeyword];
            
            break;
            
        }
    }
    
}

@end
