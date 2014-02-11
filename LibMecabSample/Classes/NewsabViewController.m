//
//  LibMecabSampleViewController.m
//  LibMecabSample
//
//  Created by Watanabe Toshinori on 10/12/27.
//  Copyright 2010 FLCL.jp. All rights reserved.
//

#import "TFHpple.h"
#import "Tutorial.h"
#import "Contributor.h"

#import "NewsabViewController.h"
#import "Mecab.h"
#import "Node.h"

@implementation NewsabViewController

@synthesize textField;
@synthesize tableView_;
@synthesize nodeCell;
@synthesize mecab;
@synthesize nodes;

- (void)viewDidLoad {
	[super viewDidLoad];
	
//	self.mecab = [[Mecab new] autorelease];
    self.mecab = [Mecab new];
}

/*
 *未実行：
 *重複回避
 *連体、連用修飾語の重要度算出(重要語句の包含度)と取捨選択ー＞cabocha
 */

- (IBAction)parse:(id)sender {
	[textField resignFirstResponder];//フォーカス外す
	
//	NSString *string = textField.text;//テキストを取得
    NSString *string = nil;
//    string = @"１月24日（ブルームバーグ）：中国で30億元（約510億円）規模の信託商品がデフォルト（債務不履行）寸前の状態に陥っている。この商品をめぐる経緯は、米資産家ジョージ・ソロス氏が先に指摘した2008年の世界金融危機と中国の債券市場との「不気味な類似点」を想起させるものだ。";
//    string = @"太郎はlinuxが大好きです。";
//    string = @"ホンダが昨年11月に公開した動画作成アプリ「ＲＯＡＤＭＯＶＩＥＳ（ロードムービーズ、ＲＭ）」の利用が拡大している。簡単な操作で誰でも完成度の高い映像が作成できるとあって、ｉＰｈｏｎｅのみの対応ながら７月末時点で累計ダウンロードは130万を超えた。一見、カーライフとはあまり関係がないアプリ。しかし、作成した動画がネットで拡散する過程で、ホンダのサービスを知るしかけが随所にちりばめられている。「ドライブに限定するよりは、使い勝手を高め、生活の中の思い出作りに役立ててほしかった」。ＲＭの開発を担当したインターナビ事業室の三河昭広主任はこう語る。24秒の動画を作成する手法は簡単だ。アプリを立ち上げて、まずは１秒×24ショット、２秒×12ショット、３秒×８ショットの３つから、動画の作成パターンを選ぶ。あとは手順に従い動画を８～24回撮影するだけ。手動撮影するのに加え、たとえば車のダッシュボードに設置して１キロごと、１時間おきなど距離（100メートル～20キロ）や時間（１分～１時間）を設定してのインターバル撮影も可能だ。24秒分の動画が撮れたら、９種類の加工フィルターを選ぶ。そのままの色調を生かせるノーマルから、白黒、映画調などがそろい、フィルターがかかると映像の完成度は格段に高まる。ＢＧＭはコマ割映像に合うようにとアーティストらに依頼した楽曲を14曲提供。映像の雰囲気に合わせて曲を選べば完成だ。動画の最後には、まるで映画のエンドロールのように、撮影日時が現れる。子どもの成長記録やバイクでのツーリング風景、海外旅行の思い出などを撮影する人が多く、画像は動画共有サイトのユーチューブやフェイスブック（ＦＢ）にアップできる。ＦＢ上には、動画と一緒にＲＭのホームページ（ＨＰ）ＵＲＬも表示される。ＨＰに飛べばホンダが運営するカーナビ連動の会員制交通情報サービス「インターナビ」などについてもわかるしかけだ。アプリ起動時には大きくはないがホンダのロゴが現れる。直接の販売促進にはならないが、長期的にみれば「学生でも簡単に使えるアプリなので、ホンダのファン育成にもなる」（三河氏）。もちろん、車やバイクを運転する人にとっては、ドライブの楽しさ向上につながる。宣伝色を消し洗練度を高めたことが、翻ってホンダの取り組みの周知につながっているようだ。";//972文字
    string = @"日銀が昨年４月にスタートさせた異次元緩和では、毎月７兆円強の国債を購入してきたが、足元ではその「目安」として示してきた７兆円強を下回ってきた。日銀は長期国債の保有残高を年間約５０兆円増加させることが、正式なコミットメントであるとの立場を明確化させている。月間の買い入れ額については、異次元緩和導入当初に示した「７兆円強」にとらわれず、弾力的に対応する考えのようだ。＜１月の購入額は６．６兆円（訂正）＞日銀による１月中の長期国債買い入れは、オファー日ベースで６兆６０００億円（訂正）にとどまった。日銀は昨年４月の金融政策決定会合の声明文の注書きに「毎月の長期国債のグロスの買い入れ額は７兆円強になる見込み」と明記。５月３０日に公表した「当面の長期国債買い入れの運営について」でも「毎月７兆円強程度」と発信しているが、昨年１２月に続く７兆円割れとなっている。市場では、年間５０兆円の国債残高増でも異次元緩和が導入された４月以降に買い入れ額を増やした２０１３年に比べ、１年間を通じて買い入れを続ける２０１４年は、単純計算で月間の買い入れ額が減少するとの思惑が昨年から取りざたされていた。異次元緩和では２％の物価安定目標を２年程度で達成するため、マネタリーベースを「年間約６０─７０兆円」増やし、長期国債の保有残高を「年間約５０兆円」増やすことを約束している。月間の国債買い入れ額について、異次元緩和の導入当初に日銀は目安として「７兆円強」という数字を示していた。ただ、日銀は、もともと月間購入額は市場動向などに応じて変動し得ると対外的に示してきたとの立場。異次元緩和の枠組みでは、資産買入のフローまではコミットしていない。黒田東彦総裁は昨年１２月の会見で「保有残高が年間約５０兆円に相当するペースで増加するよう買い入れを行うということで、実際の買入額は償還額や金融市場の動向などを踏まえて弾力的に運用する」と説明。国債残高を予定通り増やすことが重要で、毎月の買い入れ額は振れるとの見解を示している。実際、これまでの月間買い入れ額についても６兆円台─８兆円台と幅がある。日銀では、今後も国債保有額を年間５０兆円増加させることを目指し、イールドカーブ全体に低下圧力をかけるとの観点を踏まえ、月間の国債買い入れは弾力的に対応する方針。このため長期金利の急騰など市場が不安定化する場合には、１回の買い入れ額や頻度を増やす可能性がある一方、市場が安定している局面では買い入れ額が７兆円を割り込むケースがありそうだ。もっとも、その場合は、月間「７兆円強」との目安を示した公表文の解釈をめぐって詳細な説明を求められることも予想され、あらためて日銀と市場との対話のあり方に焦点があたりそうだ。(竹本能文　伊藤純夫　編集：田巻一彦)＊本文中の１月の購入額「６．４兆円」を「６．６兆円」に訂正します。";
    
    NSString *title = nil;
//    title = @"誰でも「映像作家」に 操作簡単、ホンダの動画アプリ ：日本経済新聞";
    title = @"日銀の国債月間購入額「7兆円強」にとらわれず弾力対応";
    
    
    //===========================================文字列を形態素解析
	self.nodes = [mecab parseToNodeWithString:string];//テキストをメカブで形態素解析してnodes(UITableCell)に格納
	
	[tableView_ reloadData];//格納したnodesを再表示
    //===========================================
    
    
    
    //===========================================ロイターからデータを取得
//    [self getHTML];
    NSString *contents = [self getContentsFromHTML];
    
    if([contents isEqualToString:string]){
        NSLog(@"合致");
    }
    
    //===========================================
    
    
    
    
    
    //===========================================DBからデータを取得
    
//    NSString *strTmp = [self getValueFromDB:@"1" column:@"url"];
    NSString *strTmp = [self getValueFromDB:@"1" column:@"body"];
    NSLog(@"strTmp = %@", strTmp);
    
    //
//    NSString *dictUTFNonLossyASCIIStringEncoding =
//    [NSString stringWithCString:
//     [strTmp cStringUsingEncoding:NSUTF8StringEncoding]
//                       encoding:NSNonLossyASCIIStringEncoding];
//    NSLog(@"dictUTFNonLossyASCIIStringEncoding:%@", dictUTFNonLossyASCIIStringEncoding);
    
    //===========================================
//    return;
    
    
    
//    ①タイトルに含まれている単語を含む文章は本文の要約をしている可能性が高い
//    ②上の方にある文章ほどその重要度が高い
//    ③文章全体のキーワードをカウントした時、特に上位に来るワードの重要さが大きい
//    ④tfidfが大きい文書
    
    //stringを句点(。)で分割して文章に分割
    NSArray *arrSentence = [NSArray array];//空配列
    arrSentence = [string componentsSeparatedByString:@"。"];//句点で分割
    for(int i = 0;i < [arrSentence count];i++){
        NSLog(@"sentence%d=%@", i, arrSentence[i]);
    }
    
    
    //作成した形態素のうち名詞のみ配列に格納
    NSMutableArray *arrNoun = [NSMutableArray array];
    for(int i = 0;i < [nodes count];i++){
        NSString *hinshi = ((Node *)nodes[i]).partOfSpeech;
        NSString *term = ((Node *)nodes[i]).surface;
        if([hinshi isEqualToString:@"名詞"]){
            //既に格納されていないか確認
            int noNou = 0;
            for(noNou = 0;noNou < [arrNoun count];noNou++){
                if([term isEqualToString:arrNoun[noNou]]){
                    break;
                }
            }
            if(noNou == [arrNoun count]){
                
                //特殊条件分岐:例外処理
                if(![term isEqualToString:@"の"] &&
                   ![term isEqualToString:@"ら"]){
                    [arrNoun addObject:term];
                    NSLog(@"add noun %d , %@",
                          noNou, term);
                }
            }
        }
    }
    
    
    NSLog(@"名詞格納完了");
    
    
    
//    //作成した名詞配列がどの(番号の)文章に対応するか：不要？
//    for(int noSen = 0;noSen < [arrSentence count];noSen++){
//        for(int noNou = 0;noNou < [arrNoun count];noNou++){
//            if([arrSentence[noSen] rangeOfString:arrNoun[noNou]].location == NSNotFound){
//                
//            }
//        }
//    }
    
    
    
    //文章スコア配列作成
    NSMutableArray *arrSenScore = [NSMutableArray array];
    for(int i = 0 ;i < [arrSentence count];i++){
//        NSLog(@"i = %d", i);
        [arrSenScore addObject:@0];
    }
    
    //単語スコア配列作成
    NSMutableArray *arrTerScore = [NSMutableArray array];
    for(int i = 0;i < [arrNoun count];i++){
//        NSLog(@"i = %d", i);
        [arrTerScore addObject:@0];//初期値を格納
    }
    
    //①タイトルにある単語を含む文章に得点付与
    NSLog(@"開始：①タイトルにある単語を含む文章に得点付与");
    //各文章に対して
    for(int noSen = 0;noSen < [arrSentence count];noSen++){
        //各名詞配列がその文章に含まれるかどうか探索
        for(int noNou = 0;noNou < [arrNoun count];noNou++){
            if([arrSentence[noSen] rangeOfString:arrNoun[noNou]].location != NSNotFound){
                //その名詞がタイトルに含まれている場合
                if([title rangeOfString:arrNoun[noNou]].location != NSNotFound){
                    //(その名詞が含む)文章に得点を付与
                    int _score = [arrSenScore[noSen] integerValue];
                    arrSenScore[noSen] = [NSNumber numberWithInteger:_score + 1];
                }
            }
        }
    }
    
    
    NSLog(@"開始：①-1単語にも得点付与");
    //①-1単語にも得点付与
    for(int i = 0;i < [arrNoun count];i++){
        NSRange range = [title rangeOfString:arrNoun[i]];
        if (range.location == NSNotFound) {
//            NSLog(@"not found");//確認
        }else{
            int _score = [arrTerScore[i] integerValue];
            arrTerScore[i] = [NSNumber numberWithInteger:_score+1];//付与得点は1点
        }
    }
    
    NSLog(@"開始：②上の方にある文章に得点付与");
    //②上の方にある文章に得点付与
//    for(int noSen = 0;noSen < [arrSenScore count];noSen++){
    for(int noSen = 0;noSen < 3;noSen++){
        int _score = [arrSenScore[noSen] integerValue];
        arrSenScore[noSen] = [NSNumber numberWithInteger:_score+1];
    }
    //②-1単語にも得点を付与
    for(int noSen = 0;noSen < [arrSentence count];noSen++){
        //int addScore = [arrSentence count] - noSen;//付与得点は全体文章数ー現在文章番号：文章が多い程前の文章が高評価
        int addScore = 1;
        for(int noNou = 0;noNou < [arrNoun count];noNou++){
            if([arrSentence[noSen] rangeOfString:arrNoun[noNou]].location != NSNotFound){
                int _score = [arrTerScore[noNou] integerValue];
                arrTerScore[noNou] = [NSNumber numberWithInteger:_score + addScore];//得点付与
            }
        }
    }
    
    NSLog(@"開始：③頻出上位キーワードを多く含む文章に得点付与");
    //③頻出上位キーワードを多く含む文章に得点付与
    NSLog(@"開始：各名詞に対する出現頻度格納用配列の作成と初期化");
    NSMutableArray *arrTermEmerge = [NSMutableArray array];//各名詞の出現頻度格納用の配列を作成
    for(int noNou = 0; noNou < [arrNoun count];noNou ++){
        //その名詞の出現頻度の初期化
        [arrTermEmerge addObject:[NSNumber numberWithInteger:0]];
        
        for(int noSen = 0; noSen < [arrSentence count];noSen++){
            if([arrSentence[noSen] rangeOfString:arrNoun[noNou]].location != NSNotFound){
                //出現数を更新
                arrTermEmerge[noNou] = [NSNumber numberWithInteger:[arrTermEmerge[noNou] integerValue]+1];
            }
        }
    }
    
    NSLog(@"開始：各名詞に対する出現頻度格納用配列から文書のスコアリング");
    //以下はこれまでのスコアを並べ替えたものを表示しているだけ。
    //ここでは頻出上位キーワード５タームを選定
    int numOfSelect = 5;
    //上位ランキングのインデックス番号を獲得する
    NSMutableArray *arrUpperIndex = [self getMax:arrTermEmerge numOf:numOfSelect];
    //上記で作成した頻度配列arrTermEmergeから上位numOfSelect個の名詞に得点を付与
    for(int noNou = 0;noNou < [arrNoun count];noNou++){
        //出現数上位numOfSelect個に該当するなら
        for(int i = 0;i < [arrUpperIndex count];i++){
//            NSLog(@"i = %d, arrUpperIndex=%d", i, [arrUpperIndex[i] integerValue]);
            if(noNou == [arrUpperIndex[i] integerValue]){
                //その名詞が各文章に含まれているかどうか判定
                for(int noSen = 0;noSen < [arrSentence count];noSen++){
                    if([arrSentence[noSen] rangeOfString:arrNoun[noNou]].location != NSNotFound){
                        arrSenScore[noSen] =
                        [NSNumber numberWithInteger:[arrSenScore[noSen] integerValue]+1];
                        
//                        NSLog(@"imp sen = %@", arrSentence[noSen]);
                    }
                }
            }
        }
    }
    
    //③-1:単語にも付与
    NSLog(@"開始：③-1:単語にも付与");
    for(int noNou = 0;noNou < [arrNoun count];noNou++){
        //出現数上位numOfSelect個に該当するなら
        for(int i = 0;i < [arrUpperIndex count];i++){
            if(noNou == [arrUpperIndex[i] integerValue]){
                arrTerScore[noNou] = [NSNumber numberWithInteger:[arrTerScore[noNou] integerValue]+1];
//                NSLog(@"imp term is %@", arrNoun[noNou]);
            }
        }
    }
    
    
    
    //①〜③のスコアリングの結果、文章と単語を重要度(スコア)で並べ替える
    NSLog(@"開始：①〜③のスコアリングの結果、文章と単語を重要度(スコア)で並べ替える：文章篇");
    int numOfRank = 20;
    NSMutableArray *arrSentenceInOrder = [NSMutableArray array];
    arrSentenceInOrder = [self getMax:arrSenScore numOf:MIN(numOfRank, [arrSentence count])];//スコアが高い10位の番号を取得
    for(int i = 0 ; i < [arrSentenceInOrder count]; i++){
        NSLog(@"rank%d is %@", i, arrSentence[[arrSentenceInOrder[i] integerValue]]);
    }
    
    
    NSLog(@"開始：①〜③のスコアリングの結果、文章と単語を重要度(スコア)で並べ替える：単語篇");
    NSMutableArray *arrTermInOrder = [NSMutableArray array];
    arrTermInOrder = [self getMax:arrTerScore numOf:MIN(numOfRank, [arrSentence count])];
    for(int i = 0; i < [arrTermInOrder count]; i++){
        NSLog(@"rank%d is %@", i, arrNoun[[arrTermInOrder[i] integerValue]]);
    }
}


#pragma mark -
#pragma mark Table view data source

//ロード時に呼び出される表示件数を返すメソッド
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (nodes) {
//        NSLog(@"nodes count=%d", [nodes count]);
//        for(int i = 0; i < [nodes count];i++){
//            NSLog(@"node:%d is [%@] which attributes [%@]",
//                  i, ((Node *)nodes[i]).surface, ((Node *)nodes[i]).partOfSpeech);
//        }
		return [nodes count];
	}
	
	return 0;
}

//ロード時に呼び出される表示内容を返すメソッド
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NodeCell";
    
    NodeCell *cell = (NodeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"NodeCell" owner:self options:nil];
		cell = nodeCell;
		self.nodeCell = nil;
    }
    
	Node *node = [nodes objectAtIndex:indexPath.row];
	cell.surfaceLabel.text = node.surface;
	cell.featureLabel.text = [node partOfSpeech];//[node pronunciation];
    
    //確認用
    if([[node partOfSpeech] isEqualToString:@"名詞"]){
        cell.surfaceLabel.textColor = [UIColor redColor];
    }else{
        cell.surfaceLabel.textColor = [UIColor blackColor];
    }
    
    
    return cell;
}

- (void)dealloc {
	self.mecab = nil;
	self.nodes = nil;
	
	self.textField = nil;
	self.tableView_ = nil;
	self.nodeCell = nil;
//    [super dealloc];
}

//arrArgの上位num個を返す
//①並べ替える(同時にインデックス配列arrIndの作成も行う：ex. arrArg５番目が２番目の大きさならarrInd[2]=5)
//②インデックス配列の上位num個を返す
-(NSMutableArray *)getMax:(NSMutableArray *)arrArg numOf:(int)num{
    NSMutableArray *arrInd = [NSMutableArray array];
    NSMutableArray *arrVal = [NSMutableArray array];
    for(int i = 0;i < [arrArg count];i++){
        [arrInd addObject:[NSNumber numberWithInteger:i]];//インデックス配列
        [arrVal addObject:[NSNumber numberWithInteger:[arrArg[i] integerValue]]];//値配列
//        NSLog(@"%dを追加", [arrVal[i] integerValue]);
    }
    
    //bubble sort start
    for(int i =0;i < [arrVal count];i++){
        for(int j = 1;j < [arrVal count] - i;j++){//j=1〜
            if([arrVal[j-1] integerValue] < [arrVal[j] integerValue]){
                //swap of arrArg
                id tmp = arrVal[j];
                arrVal[j] = arrVal[j-1];
                arrVal[j-1] = tmp;
                
                
                //swap of arrInd
                tmp = arrInd[j];
                arrInd[j] = arrInd[j-1];
                arrInd[j-1] = tmp;
            }
        }
    }
    //bubble sort complete
    
    //確認用
//    for(int i = 0;i < [arrVal count];i++){
//        NSLog(@"confirm %d : score is %d", [arrInd[i] integerValue], [arrVal[i] integerValue]);
//    }
    
    NSMutableArray *arrReturn = [NSMutableArray array];
    for(int i = 0;i < num;i++){
        [arrReturn addObject:arrInd[i]];
    }
    return arrReturn;
    
    
}

-(BOOL)isInArrayAt:(NSMutableArray *)array value:(id)value{
    for(int i = 0 ;i < [array count];i++){
        if([array[i] isEqual:value]){
            return YES;
        }
    }
    return NO;
}

-(void)getHTML{
    
    
    // request
//    [NSURL URLWithString:@"http://www.objectivec-iphone.com/foundation.html#top"]
//	NSURL *url = [NSURL URLWithString:textfield1.text];
//    NSURL *url = [NSURL URLWithString:@"http://www.objectivec-iphone.com/foundation.html#top"];
    NSURL *url = [NSURL URLWithString:@"http://jp.reuters.com/article/vcJPboj/idJPTYEA1308O20140204"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [
                    NSURLConnection
                    sendSynchronousRequest : request
                    returningResponse : &response
                    error : &error
                    ];
    
    
    
    //========================================================================
    //xmlパーサーによる解析
    //http://ameblo.jp/xcc/entry-10558743900.html
    NSXMLParser *parser = [[NSXMLParser alloc]initWithContentsOfURL:url];
    [parser setDelegate:self];
    BOOL result = [parser parse];//このパーサーでは閉じられないタグ<META>があるため途中で停止してしまうのでこの方法は断念
    NSLog(@"result = %d" , result);
    //========================================================================
    
    
    
	// error
	NSString *error_str = [error localizedDescription];
	if (0<[error_str length]) {
		UIAlertView *alert = [
                              [UIAlertView alloc]
                              initWithTitle : @"RequestError"
                              message : error_str
                              delegate : nil
                              cancelButtonTitle : @"OK"
                              otherButtonTitles : nil
                              ];
		[alert show];
//		[alert release];
		return;
	}
    
	// response
	int enc_arr[] = {
		NSUTF8StringEncoding,			// UTF-8
		NSShiftJISStringEncoding,		// Shift_JIS
		NSJapaneseEUCStringEncoding,	// EUC-JP
		NSISO2022JPStringEncoding,		// JIS
		NSUnicodeStringEncoding,		// Unicode
		NSASCIIStringEncoding			// ASCII
	};
	NSString *data_str = nil;
	int max = sizeof(enc_arr) / sizeof(enc_arr[0]);
	for (int i=0; i<max; i++) {
		data_str = [
                    [NSString alloc]
                    initWithData : data
                    encoding : enc_arr[i]
                    ];
		if (data_str!=nil) {
			break;
		}
	}
    
    
//    NSLog(@"str = %@", data_str);
    
    
    //stock-price
    

    
}


//==========XMLParser======================
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    NSLog(@"Did start element at %@;", elementName);
//    if ( [elementName isEqualToString:@"root"])
//    NSString* className = [attributeDict valueForKey:@"class"];
//    if([className isEqualToString:@"socBut"])
//    {
//        NSLog(@"found rootElement");
//        return;
//    }else{
//        NSLog(@"not found class tag");
//        return;
//    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    NSLog(@"Did end element at %@;", elementName);
//    if ([elementName isEqualToString:@"root"])
//    {
//        NSLog(@"rootelement end");
//    }
    
}
- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    NSLog(@"found character %@;", string);
//    NSString *tagName = @"column";
//    
//    if([tagName isEqualToString:@"column"])
//    {
//        NSLog(@"Value %@",string);
//    }
    
}
//==========XMLParser======================



//==========HTMLParser:using hpple==================

//html parser:http://www.raywenderlich.com/14172/how-to-parse-html-on-ios
-(NSString *)getContentsFromHTML{
    NSLog(@"loadTutorials");
    // 1
//    NSURL *tutorialsUrl = [NSURL URLWithString:@"http://www.raywenderlich.com/tutorials"];
//    NSURL * tutorialsUrl = [NSURL URLWithString:@"http://jp.reuters.com/article/vcJPboj/idJPTYEA1308O20140204"];
    NSURL *tutorialsUrl = [NSURL URLWithString:@"http://jp.reuters.com/article/topNews/idJPTYEA1406X20140205?sp=true"];
    
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    // 2
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    // 3：次を探索：
    /*
     <div class="content-wrapper">
        <h3>Beginning iPhone Programming</h3>
        <ul>
            <li><a href="/?p=1797">How To Create a Simple iPhone App on iOS 5 Tutorial: 1/3</a></li>
            <li><a href="/?p=1845">How To Create a Simple iPhone App on iOS 5 Tutorial: 2/3</a></li>
            <li><a href="/?p=1888">How To Create a Simple iPhone App on iOS 5 Tutorial: 3/3</a></li>
            <li><a href="/?p=10209">My App Crashed &#8211; Now What? 1/2</a></li>
            <li><a href="/?p=10505">My App Crashed &#8211; Now What? 2/2</a></li>
            <li><a href="/?p=8003">How to Submit Your App to Apple: From No Account to App Store, Part 1</a></li>
            <li><a href="/?p=8045">How to Submit Your App to Apple: From No Account to App Store, Part 2</a></li>
        </ul>
     </div>
     */
//    NSString *tutorialsXpathQueryString = @"//div[@class='content-wrapper']/ul/li/a";
    
    
    
    /*
     *以下のパターンを検索
     <span class="focusParagraph">
        <p>［東京　４日　ロイター］ -日銀が昨年４月にスタートさせた異次元緩和では、毎月７兆円強の国債を購入してきたが、足元ではその「目安」として示してきた７兆円強を下回ってきた。
        <span id="midArticle_byline">
     
        </span>
        </p>
     </span>
     */
    NSString *tutorialsXpathQueryString = @"//span[@class='focusParagraph']/p";
    
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // 4
    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in tutorialsNodes) {
        // 5
        Tutorial *tutorial = [[Tutorial alloc] init];
        [newTutorials addObject:tutorial];
        
        // 6
        tutorial.title = [[element firstChild] content];
        
        // 7
        tutorial.url = [element objectForKey:@"href"];
    }
    
    // 8:内容を確認
    NSString *contents = [NSString stringWithFormat:@""];
    for(int i = 0;i < [newTutorials count];i ++){
        NSLog(@"%d is %@", i, ((Tutorial *)newTutorials[i]).title);
        if(((Tutorial *)newTutorials[i]).url){
            NSLog(@"%d is %@", i, ((Tutorial *)newTutorials[i]).url);
        }
        
        contents = [NSString stringWithFormat:@"%@%@",
                    contents,
                    ((Tutorial *)newTutorials[i]).title];
    }
    
    NSLog(@"contents = %@",contents);
    
    NSLog(@"%d tutorials complete", [newTutorials count]);
    
    
    return contents;
    
}



-(NSString *)getValueFromDB:(NSString *)user_id column:(NSString *)column{
    
    //phpファイルの以下の変数にそれぞれ格納される：$sql = "select $_POST[item] from dbusermanage where id = '$_POST[id]'";
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:user_id forKey:@"id"];
    [dict setObject:column forKey:@"item"];
    NSData *data = [self formEncodedDataFromDictionary:dict];
//    NSURL *url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/getvalue.php"];
    NSURL *url = [NSURL URLWithString:@"http://test-lolipop-sql.lolipop.jp/junkai/managedb/getvalue.php"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:data];
    
    NSURLResponse *response;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:req
                                           returningResponse:&response
                                                       error:&error];
    if(error){
        NSLog(@"同期通信失敗");
        return nil;
    }else{
        NSLog(@"同期通信成功->%@", result);
    }
    
    
    NSString* resultString = [[NSString alloc] initWithData:result
                                                   encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    NSLog(@"getValueFromDB = %@", resultString);
    
    return resultString;
}

- (NSData *)formEncodedDataFromDictionary:(NSDictionary *)dict
{
    NSMutableString *str;
    
    str = [NSMutableString stringWithCapacity:0];
    
    // 「キー=値」のペアを「&」で結合して列挙する
    // キーと値はどちらもURLエンコードを行い、スペースは「+」に置き換える
    for (NSString __strong *key in [dict allKeys])
    {
        //        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *value = [dict objectForKey:key];
        
        // スペースを「+」に置き換える
        key = [key stringByReplacingOccurrencesOfString:@" "
                                             withString:@"+"];
        value = [value stringByReplacingOccurrencesOfString:@" "
                                                 withString:@"+"];
        
        
        // URLエンコードを行う
        key = [key stringByAddingPercentEscapesUsingEncoding:
               NSUTF8StringEncoding];
        value = [value stringByAddingPercentEscapesUsingEncoding:
                 NSUTF8StringEncoding];
        
        // 文字列を連結する
        if ([str length] > 0)
        {
            [str appendString:@"&"];
        }
        
        [str appendFormat:@"%@=%@", key, value];
        //        [pool drain];
    }
    
    // 作成した文字列をUTF-8で符号化する
    NSData *data;
    data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"str = %@", str);//ex.str = id=1&item=title
    NSLog(@"return data = %@", data);//ex.return data = <69643d31 26697465 6d3d7469 746c65>
    return data;
}

@end
