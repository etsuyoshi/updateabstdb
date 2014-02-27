//
//  TextViewController.h
//  UpdateAbstDB
//
//  Created by 遠藤 豪 on 2014/02/26.
//
//

#import <UIKit/UIKit.h>
#import "ArticleData.h"

@interface TextViewController : UIViewController
@property (nonatomic) NSString *strTitle;
@property (nonatomic, copy) NSString *strText;

-(id)initWithArticle:(ArticleData *)articleData;



@end
