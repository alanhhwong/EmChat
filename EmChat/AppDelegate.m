//
//  AppDelegate.m
//  EmChat
//
//  Created by Alan Wong on 14/3/15.
//  Copyright (c) 2015 Alan Wong. All rights reserved.
//

#import "AppDelegate.h"
#import <LayerKit/LayerKit.h>
#import "Atlas.h"
#import <MessageUI/MessageUI.h>
#import <sys/sysctl.h>
#import <asl.h>

#import "ATLMNavigationController.h"
#import "ATLMConversationListViewController.h"
#import "ATLMSplashView.h"
#import "ATLMQRScannerController.h"
#import "ATLMUtilities.h"

#import "MainViewController.h"

// TODO: Configure a Layer appID from https://developer.layer.com/dashboard/atlas/build
static NSString *const ATLMLayerAppID = @"6b60f7f0-ca7c-11e4-a5c8-eae84600392d";

@interface AppDelegate ()
@property (nonatomic) ATLMQRScannerController *scannerController;
@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) ATLMConversationListViewController *conversationListViewController;
@property (nonatomic) ATLMSplashView *splashView;
@end

@implementation AppDelegate

-(void) showMainWindow:(Person*) person {
    MainViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[person toDictionary] forKey:@"loggedInPerson"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    viewController.me = person;
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    self.window.rootViewController = navController;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.applicationController = [ATLMApplicationController controllerWithPersistenceManager:[ATLMPersistenceManager defaultManager]];
    
    self.scannerController = [ATLMQRScannerController new];
    self.scannerController.applicationController = self.applicationController;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.scannerController];
    self.navigationController.navigationBarHidden = YES;
    
    // Setup Layer
    [self setupLayer];
    
    // Configure Atlas Messenger UI appearance
    [self configureGlobalUserInterfaceAttributes];
    
    // Setup notifications
    [self registerNotificationObservers];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedInPerson"];
    if (dict) {
        [self showMainWindow:[[Person alloc] initWithDictionary:dict]];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
        [self setApplicationBadgeNumber];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self resumeSession];
    [self setupLayer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupLayer
{
    NSString *appID = ATLMLayerAppID ?ATLMLayerAppID: [[NSUserDefaults standardUserDefaults] valueForKey:ATLMLayerApplicationID];
    
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:ATLMLayerApplicationID];
    if (appID) {
        ATLMLayerClient *layerClient = [ATLMLayerClient clientWithAppID:[[NSUUID alloc] initWithUUIDString:appID]];
        layerClient.autodownloadMIMETypes = [NSSet setWithObjects:ATLMIMETypeImageJPEGPreview, ATLMIMETypeTextPlain, nil];
        ATLMAPIManager *manager = [ATLMAPIManager managerWithBaseURL:ATLMRailsBaseURL() layerClient:layerClient];
        self.applicationController.layerClient = layerClient;
        self.applicationController.APIManager = nil;
        [self connectLayerIfNeeded];
        if (![self resumeSession]) {
            [self.scannerController presentRegistrationViewController];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //[self removeSplashView];
            });
        }
    } else {
        //[self removeSplashView];
    }
}

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerAppID:) name:ATLMDidReceiveLayerAppID object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAuthenticate:) name:ATLMUserDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(userDidAuthenticateWithLayer:) name:LYRClientDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeauthenticate:) name:ATLMUserDidDeauthenticateNotification object:nil];
}

#pragma mark - Session Management

- (BOOL)resumeSession
{
    if (self.applicationController.layerClient.authenticatedUserID) {
        ATLMSession *session = [self.applicationController.persistenceManager persistedSessionWithError:nil];
        if ([self.applicationController.APIManager resumeSession:session error:nil]) {
            [self presentConversationsListViewController:YES];
            return YES;
        }
    }
    return NO;
}

- (void)connectLayerIfNeeded
{
    if (!self.applicationController.layerClient.isConnected && !self.applicationController.layerClient.isConnecting) {
        [self.applicationController.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
            NSLog(@"Layer Client Connected");
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.applicationController registerAndAuthenticateUserWithName:@"test1"];
//            });
        }];
    }
}

#pragma mark - Push Notifications

- (void)registerForRemoteNotifications:(UIApplication *)application
{
    // Registers for push on iOS 7 and iOS 8
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    }
}

- (void)unregisterForRemoteNotifications:(UIApplication *)application
{
    [application unregisterForRemoteNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Application failed to register for remote notifications with error %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSError *error;
    BOOL success = [self.applicationController.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (success) {
        NSLog(@"Application did register for remote notifications");
    } else {
        NSLog(@"Error updating Layer device token for push:%@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    BOOL userTappedRemoteNotification = application.applicationState == UIApplicationStateInactive;
    __block LYRConversation *conversation = [self conversationFromRemoteNotification:userInfo];
    if (userTappedRemoteNotification && conversation) {
        [self navigateToViewForConversation:conversation];
    } else if (userTappedRemoteNotification) {
        //[SVProgressHUD showWithStatus:@"Loading Conversation" maskType:SVProgressHUDMaskTypeBlack];
    }
    
    BOOL success = [self.applicationController.layerClient synchronizeWithRemoteNotification:userInfo completion:^(NSArray *changes, NSError *error) {
        [self setApplicationBadgeNumber];
        if (changes.count) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(error ? UIBackgroundFetchResultFailed : UIBackgroundFetchResultNoData);
        }
        
        // Try navigating once the synchronization completed
        if (userTappedRemoteNotification && !conversation) {
            //[SVProgressHUD dismiss];
            conversation = [self conversationFromRemoteNotification:userInfo];
            [self navigateToViewForConversation:conversation];
        }
    }];
    
    if (!success) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return YES;
}

- (LYRConversation *)conversationFromRemoteNotification:(NSDictionary *)remoteNotification
{
    NSURL *conversationIdentifier = [NSURL URLWithString:[remoteNotification valueForKeyPath:@"layer.conversation_identifier"]];
    return [self.applicationController.layerClient existingConversationForIdentifier:conversationIdentifier];
}

- (void)navigateToViewForConversation:(LYRConversation *)conversation
{
    if (![NSThread isMainThread]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Attempted to navigate UI from non-main thread" userInfo:nil];
    }
    [self.conversationListViewController selectConversation:conversation];
}

#pragma mark - Authentication Notification Handlers

- (void)didReceiveLayerAppID:(NSNotification *)notification
{
    [self setupLayer];
}

- (void)userDidAuthenticateWithLayer:(NSNotification *)notification
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self userDidAuthenticateWithLayer:notification];
        });
        return;
    }
    [self presentConversationsListViewController:YES];
}

- (void)userDidAuthenticate:(NSNotification *)notification
{
    NSError *error;
    ATLMSession *session = self.applicationController.APIManager.authenticatedSession;
    BOOL success = [self.applicationController.persistenceManager persistSession:session error:&error];
    if (success) {
        NSLog(@"Persisted authenticated user session: %@", session);
    } else {
        NSLog(@"Failed persisting authenticated user: %@. Error: %@", session, error);
    }
}

- (void)userDidDeauthenticate:(NSNotification *)notification
{
    NSError *error;
    BOOL success = [self.applicationController.persistenceManager persistSession:nil error:&error];
    if (success) {
        NSLog(@"Cleared persisted user session");
    } else {
        NSLog(@"Failed clearing persistent user session: %@", error);
        //TODO - Handle Error
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        self.conversationListViewController = nil;
        [self setupLayer];
    }];
    
    [self unregisterForRemoteNotifications:[UIApplication sharedApplication]];
}

#pragma mark - Conversations

- (void)presentConversationsListViewController:(BOOL)animated
{
    if (self.conversationListViewController) return;
    self.conversationListViewController = [ATLMConversationListViewController conversationListViewControllerWithLayerClient:self.applicationController.layerClient];
    self.conversationListViewController.applicationController = self.applicationController;
    
    ATLMNavigationController *authenticatedNavigationController = [[ATLMNavigationController alloc] initWithRootViewController:self.conversationListViewController];
    [self.navigationController presentViewController:authenticatedNavigationController animated:YES completion:^{
        //[self removeSplashView];
    }];
}

#pragma mark - UI Config

- (void)configureGlobalUserInterfaceAttributes
{
    [[UINavigationBar appearance] setTintColor:ATLBlueColor()];
    [[UINavigationBar appearance] setBarTintColor:ATLLightGrayColor()];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:ATLBlueColor()];
}

#pragma mark - Application Badge Setter

- (void)setApplicationBadgeNumber
{
    NSUInteger countOfUnreadMessages = [self.applicationController.layerClient countOfUnreadMessages];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:countOfUnreadMessages];
}



@end
