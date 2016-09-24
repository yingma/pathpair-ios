//
//  ChatViewController.m
//  SocialTracker
//
//  Created by Admin on 7/9/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "Data/Room.h"
#import "Http/ServiceEngine.h"
#import "Http/ServiceMessage.h"
#import "Http/WebSocketEngine.h"
#import "JSQMessagesCollectionViewFlowLayout.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "UIColor+JSQMessages.h"
#import "DetailTableViewController.h"



@interface ChatViewController ()

@end

@implementation ChatViewController {
    
    AppDelegate *_theApp;
    NSMutableDictionary *_avatarCache;
    JSQMessagesBubbleImage *_outgoingBubbleImage;
    JSQMessagesBubbleImage *_incomingBubbleImage;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageDidChange:)
                                                 name:kMessageChangeNotification
                                               object:nil];
    
    _avatarCache = [NSMutableDictionary dictionary];
    
    JSQMessagesAvatarImage *placeHoldAvatar = [JSQMessagesAvatarImageFactory avatarImageWithPlaceholder:[UIImage imageNamed:@"profile"]
                                                                                         diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    [_avatarCache setObject:placeHoldAvatar forKey:@"placehold"];
    
    if ([[NSUserDefaults standardUserDefaults] dataForKey:kPhotoKey] != nil) {
    
        JSQMessagesAvatarImage *selfAvatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] dataForKey:kPhotoKey]] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        [_avatarCache setObject:selfAvatar forKey:[[ServiceEngine sharedEngine] uid]];
    }
    
    /**
     *  Create message bubble images objects.
     *
     *  Be sure to create your bubble images one time and reuse them for good performance.
     *
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    _outgoingBubbleImage = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    _incomingBubbleImage = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    assert(self.room != nil);
    //self.title = self.room.name;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [_theApp setBadgeChat:-[_room.badge integerValue]];
    
    _room.badge = [NSNumber numberWithInteger:0];
    
    [_theApp saveContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMessageChangeNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"action"]) {
        DetailTableViewController *controller = [segue destinationViewController];
        controller.contact = self.contact;
    }
}


#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return [[ServiceEngine sharedEngine] uid];
}

- (NSString *)senderDisplayName {
    return [[ServiceEngine sharedEngine] uid];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Message *message = [self.room.messages objectAtIndex:indexPath.item];
    return [JSQMessage messageWithSenderId:message.uid
                               displayName:message.uid
                                      text:message.text];
}


- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    Message *message = [self.room.messages objectAtIndex:indexPath.item];
    
    if ([message.uid isEqualToString:[[ServiceEngine sharedEngine] uid]]) {
        return _outgoingBubbleImage;
    }
    
    return _incomingBubbleImage;
}



- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    Message *message = [self.room.messages objectAtIndex:indexPath.item];
    
    if ([_avatarCache objectForKey:message.uid]) {
        return [_avatarCache objectForKey:message.uid];
    }
    else {
        
        Contact *contact = [_theApp getContactbyUid:message.uid];
        NSLog(@"%@", message.uid);
        
//        if (contact.image == nil)
            [[ServiceEngine sharedEngine] downloadPhoto:contact.photourl
                                            withSuccess:^(UIImage * _Nullable image) {
                                            
                                                JSQMessagesAvatarImage *avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                                                            diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                                                [_avatarCache setObject:avatar forKey:contact.uid];
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self.collectionView reloadData];
                                                });
                                                
        
                                          } failure:^(NSError * _Nullable error) {
        
                                          }];
//        else {
//            
//            JSQMessagesAvatarImage *avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:contact.image
//                                                                                        diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
//            [_avatarCache setObject:avatar forKey:contact.uid];
//        }

    }
    
    
    return [_avatarCache objectForKey:@"placehold"];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    Message *message = [self.room.messages objectAtIndex:indexPath.item];
    
    if (indexPath.item > 0) {
        Message *lastMessage = [self.room.messages objectAtIndex:indexPath.item - 1];
        if ([message.utime timeIntervalSinceDate:lastMessage.utime] > 3600) {
            [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.utime];
        }
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}



#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.room.messages.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    Message *message = [self.room.messages objectAtIndex:indexPath.item];
    
    if ([message.uid isEqualToString:[[ServiceEngine sharedEngine] uid]]) {
            cell.textView.textColor = [UIColor blackColor];
    } else {
            cell.textView.textColor = [UIColor whiteColor];
    }
        
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                           NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    
    return cell;
}

#pragma mark - JSQMessagesViewController method overrides

NSString *const kMessageSequence       = @"MessageSequence";

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    Message *message = [_theApp newMessage:text andUser:senderId];
    [self.room addMessagesObject:message];
    NSInteger seq = [[NSUserDefaults standardUserDefaults] integerForKey:kMessageSequence];
    message.sequence = [NSNumber numberWithInteger: ++ seq];
    [_theApp saveContext];
    
    [[NSUserDefaults standardUserDefaults] setInteger:seq
                                               forKey:kMessageSequence];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // enter the room
    NSDictionary *parameters = @{kAppSocketRoomId: self.room.rid, kAppSocketMessage : text, kAppSocketSequence : [NSString stringWithFormat: @"%ld", (long)seq]};
    NSArray *array = [NSArray arrayWithObject:parameters];
    
    [[WebSocketEngine sharedEngine] emitWithAck:@"send"
                                           args:array
                          withCompletionHandler:^() {
                              
                              NSLog(@"%@", array);
                              
                          }];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - message received method overrides

- (void) messageDidChange: (NSNotification*) aNotification {
    
    NSDictionary* info = [aNotification object];
    ServiceMessage *m = [info objectForKey:@"message"];
    
    if (![m.room isEqualToString:self.room.rid])
        return;
    
    if (m.type == MessageTypeTyping) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.showTypingIndicator = !self.showTypingIndicator;
        });
        
    } else if (m.type == MessageTypeNew || m.type == MessageTypeUnsubscribe){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self finishReceivingMessageAnimated:YES];
            [_theApp setBadgeChat:-[_room.badge integerValue]];
            _room.badge = [NSNumber numberWithInteger:0];
            [_theApp saveContext];
        });
    }
    
}



@end
