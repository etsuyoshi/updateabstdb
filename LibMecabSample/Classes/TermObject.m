//
//  TermObject.m
//  UpdateAbstDB
//
//  Created by 遠藤 豪 on 2014/03/16.
//
//

#import "TermObject.h"

@implementation TermObject

@synthesize idea;

@synthesize surface;
@synthesize surfaces;
@synthesize originalForms;
@synthesize partOfSpeeches;
@synthesize partOfSpeechSubtypes1;
@synthesize partOfSpeechSubtypes2;
@synthesize partOfSpeechSubtypes3;
@synthesize inflections;


//-(id)initWithNode

-(void)setNode:(Node *)nodeArg{
    
//    まだ何も格納されていなければまずはフィールドの初期化
    if(self.originalForms == nil || [self.originalForms isEqual:[NSNull null]]){
        self.surface = @"";
        self.surfaces = [NSMutableArray array];
        self.originalForms = [NSMutableArray array];
        self.partOfSpeeches = [NSMutableArray array];
        self.partOfSpeechSubtypes1 = [NSMutableArray array];
        self.partOfSpeechSubtypes2 = [NSMutableArray array];
        self.partOfSpeechSubtypes3 = [NSMutableArray array];
        self.inflections = [NSMutableArray array];
    }
    
    
    self.surface = [NSString stringWithFormat:@"%@%@", self.surface, nodeArg.surface];
    [self.surfaces addObject:nodeArg.surface];
    [self.originalForms addObject:nodeArg.originalForm];
    [self.partOfSpeeches addObject:nodeArg.partOfSpeech];
    [self.partOfSpeechSubtypes1 addObject:nodeArg.partOfSpeechSubtype1];
    [self.partOfSpeechSubtypes2 addObject:nodeArg.partOfSpeechSubtype2];
    [self.partOfSpeechSubtypes3 addObject:nodeArg.partOfSpeechSubtype3];
    [self.inflections addObject:nodeArg.inflection];

    
//    3(名詞,数,*,*)
//    月(名詞,一般,*,*)
//    14(名詞,数,*,*)
//    日(名詞,接尾,助数詞,*)
    
    
    //当該単語が示している概念の類推
    
    
    //日付データの認識
    if([self.surfaces count] > 1){
        
    }
    
}


@end
