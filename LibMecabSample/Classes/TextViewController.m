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

@synthesize strTitle;
@synthesize strText;

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
        self.strTitle = articleData.title;
        self.strText = articleData.text;
        
        NSLog(@"strTitle=%@", self.strTitle);
        NSLog(@"strText=%@", self.strText);
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
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 50)];
    lblTitle.text = self.strTitle;
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:.5f];
    lblTitle.numberOfLines = 1;
    [self.view addSubview:lblTitle];
    
    UILabel *lblText=[[UILabel alloc]initWithFrame:CGRectMake(0, lblTitle.frame.origin.y + lblTitle.bounds.size.height,
                                                              self.view.bounds.size.width, 300)];
    lblText.text = self.strText;
    lblText.textColor = [UIColor blackColor];
    lblText.backgroundColor=[UIColor colorWithRed:0 green:1.0f blue:0 alpha:0.5f];//[UIColor clearColor];
    lblText.numberOfLines = 0;
    [self.view addSubview:lblText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
