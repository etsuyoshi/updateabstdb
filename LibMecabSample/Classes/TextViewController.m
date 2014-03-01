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
        
        
        NSString *_strText = articleData.arrImportantSentence[0];//temporary
        for(int i = 1;i < [articleData.arrImportantSentence count];i++){
            _strText = [NSString stringWithFormat:
                        @"%@,%@",_strText,articleData.arrImportantSentence[i]];
        }
        self.strText = _strText;
        
        
        NSString *_strKeyword = ((Node *)articleData.arrImportantNode[0]).surface;//temporary
        for(int i = 1;i < [articleData.arrImportantNode count];i++){
            _strKeyword = [NSString stringWithFormat:
                           @"%@,%@", _strKeyword,((Node *)articleData.arrImportantNode[i]).surface];
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
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 50)];
    lblTitle.text = self.strTitle;
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:.5f];
    lblTitle.numberOfLines = 1;
    [self.view addSubview:lblTitle];
    
    //本文
    UILabel *lblText=[[UILabel alloc]initWithFrame:CGRectMake(0, lblTitle.frame.origin.y + lblTitle.bounds.size.height,
                                                              self.view.bounds.size.width, 400)];
    lblText.text = self.strText;
    lblText.textColor = [UIColor blackColor];
    lblText.backgroundColor=[UIColor colorWithRed:0 green:1.0f blue:0 alpha:0.5f];//[UIColor clearColor];
    lblText.numberOfLines = 0;
    [self.view addSubview:lblText];
    
    
    //キーワード
    UILabel *lblKeyword=[[UILabel alloc]initWithFrame:CGRectMake(0, lblText.frame.origin.y + lblText.bounds.size.height,
                                                              self.view.bounds.size.width, 100)];
    lblKeyword.text = self.strKeyword;
    lblKeyword.textColor = [UIColor blackColor];
    lblKeyword.backgroundColor=[UIColor colorWithRed:0 green:0 blue:1.0f alpha:0.5f];//[UIColor clearColor];
    lblKeyword.numberOfLines = 3;
    [self.view addSubview:lblKeyword];
    
    
    returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [returnButton setBackgroundColor:[UIColor redColor]];
    returnButton.frame = CGRectMake(10, 10, 100, 40);
    
    [returnButton addTarget:self
                     action:@selector(onTappedReturnButton:)
           forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:returnButton];
    
    
    
    uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [uploadButton setBackgroundColor:[UIColor blueColor]];
    uploadButton.frame = CGRectMake(10, 10, 100, 40);
    
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
            [DatabaseManage updateValueToDB:[NSString stringWithFormat:@"%d",self.idNo]
                                     column:@"ispostblog"
                                     newVal:@"1"];
            
            break;
            
        }
    }
    
}

@end
