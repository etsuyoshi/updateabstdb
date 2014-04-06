//
//  TextViewController.h
//  UpdateAbstDB
//
//  Created by 遠藤 豪 on 2014/02/26.
//
//

#import <UIKit/UIKit.h>
#import "ArticleData.h"
#import "Node.h"
#import "DatabaseManage.h"

@interface TextViewController : UIViewController
@property (nonatomic) int idNo;
@property (nonatomic) NSString *strTop;
@property (nonatomic) NSString *strMiddle;
@property (nonatomic) NSString *strBottom;

-(id)initWithArticle:(ArticleData *)articleData;



@end
