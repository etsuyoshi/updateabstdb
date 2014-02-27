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

@synthesize strText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithText:(NSString *)_strArg{
    self = [super init];
    if(self){
        self.strText = _strArg;
        
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
    
    
    UILabel *lblText=[[UILabel alloc]initWithFrame:self.view.bounds];
    lblText.text = self.strText;
    lblText.textColor = [UIColor blackColor];
    lblText.backgroundColor=[UIColor clearColor];
    lblText.numberOfLines = 0;
    [self.view addSubview:lblText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
