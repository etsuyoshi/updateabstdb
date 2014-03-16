//
//  TermObject.h
//  UpdateAbstDB
//
//  Created by 遠藤 豪 on 2014/03/16.
//  surfaceと意味(日時、人名、地名、等が分かれば一番良い
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface TermObject : NSObject

/*Nodeオブジェクトのフィールドライクなものを全て配列として受け継ぐ
 *NSLog(@"surface:[%@]", nextNode.surface);
 NSLog(@"original:[%@]", nextNode.originalForm);
 NSLog(@"partOfSpeech:[%@]", nextNode.partOfSpeech);
 NSLog(@"partOfSpeechSubtype1:[%@]", nextNode.partOfSpeechSubtype1);
 NSLog(@"partOfSpeechSubtype2:[%@]", nextNode.partOfSpeechSubtype2);
 NSLog(@"partOfSpeechSubtype3:[%@]", nextNode.partOfSpeechSubtype3);
 NSLog(@"inflection:[%@]", nextNode.inflection);
 NSLog(@"useOfType:[%@]", nextNode.useOfType);
 NSLog(@"reading:[%@]", nextNode.reading);
 NSLog(@"pronunciation:[%@]", nextNode.pronunciation);
 */


@property (nonatomic, retain) NSString *idea;


@property (nonatomic, retain) NSString *surface;
@property (nonatomic, retain) NSMutableArray *surfaces;
@property (nonatomic, retain) NSMutableArray *originalForms;
@property (nonatomic, retain) NSMutableArray *partOfSpeeches;
@property (nonatomic, retain) NSMutableArray *partOfSpeechSubtypes1;
@property (nonatomic, retain) NSMutableArray *partOfSpeechSubtypes2;
@property (nonatomic, retain) NSMutableArray *partOfSpeechSubtypes3;
@property (nonatomic, retain) NSMutableArray *inflections;


-(void)setNode:(Node *)nodeArg;


@end
