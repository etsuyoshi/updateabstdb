//
//  ArticleData.h
//  UpdateAbstDB
//
//  Created by 遠藤 豪 on 2014/02/27.
//
//

#import <Foundation/Foundation.h>

@interface ArticleData : NSObject

@property (nonatomic) NSString *title;
//@property (nonatomic) NSString *text;

@property (nonatomic) NSArray *arrImportantSentence;
@property (nonatomic) NSArray *arrImportantNode;

@end
