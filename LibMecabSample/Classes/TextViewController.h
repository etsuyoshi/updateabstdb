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
@property (nonatomic) NSString *strTitle;
@property (nonatomic, copy) NSString *strText;
@property (nonatomic) NSString *strKeyword;

-(id)initWithArticle:(ArticleData *)articleData;



@end
