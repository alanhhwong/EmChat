//
//  ATLMApplicationController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLMApplicationController.h"
#import "ATLMConversationViewController.h"
//#import "ATLMUtilities.h"
#import "AppDelegate.h"

NSString *const ATLMLayerApplicationID = @"LAYER_APP_ID";

NSString *const ATLMConversationMetadataDidChangeNotification = @"LSConversationMetadataDidChangeNotification";
NSString *const ATLMConversationParticipantsDidChangeNotification = @"LSConversationParticipantsDidChangeNotification";
NSString *const ATLMConversationDeletedNotification = @"LSConversationDeletedNotification";

@interface ATLMApplicationController ()

@end

@implementation ATLMApplicationController

+ (instancetype)controllerWithPersistenceManager:(ATLMPersistenceManager *)persistenceManager
{
    NSParameterAssert(persistenceManager);
    return [[self alloc] initWithPersistenceManager:persistenceManager];
}

- (id)initWithPersistenceManager:(ATLMPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        _persistenceManager = persistenceManager;
    }
    return self;
}

- (LYRConversation *) conversationWithParticipants:(NSSet *)participants
{
    LYRClient *client = self.layerClient;
    NSError *error = nil;
    
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedInPerson"];
    if (dict) {
        Person *person = [[Person alloc] initWithDictionary:dict];
        NSSet *participantsIncludingAuthenticatedUser = [participants setByAddingObject:person._id];
        query.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:participantsIncludingAuthenticatedUser];
        NSSet *conversations = [[client executeQuery:query error:&error] set];
        
        LYRConversation *conversation = [conversations anyObject];
        if (!conversation) {
            conversation = [client newConversationWithParticipants:participantsIncludingAuthenticatedUser options:nil error:&error];
        }
        
        return conversation;
    }
    
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLayerClient:(ATLMLayerClient *)layerClient
{
    _layerClient = layerClient;
    _layerClient.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerClientWillBeginSynchronizationNotification:) name:LYRClientWillBeginSynchronizationNotification object:layerClient];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerClientDidFinishSynchronizationNotification:) name:LYRClientDidFinishSynchronizationNotification object:layerClient];
}

- (void)setAPIManager:(ATLMAPIManager *)APIManager
{
    _APIManager = APIManager;
    _APIManager.persistenceManager = self.persistenceManager;
}

#pragma mark - LYRClientDelegate

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
    NSLog(@"Layer Client did recieve authentication challenge with nonce: %@", nonce);
    ATLMUser *user = self.APIManager.authenticatedSession.user;
    if (!user) return;
    //TODO - Handle Auth Challenge;
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID
{
    NSLog(@"Layer Client did recieve authentication nonce");
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client
{
    [self.APIManager deauthenticate];
    NSLog(@"Layer Client did deauthenticate");
}

- (void)layerClient:(LYRClient *)client objectsDidChange:(NSArray *)changes
{
    NSLog(@"Layer Client objects did change");
    for (NSDictionary *change in changes) {
        id changedObject = change[LYRObjectChangeObjectKey];
        if (![changedObject isKindOfClass:[LYRConversation class]]) continue;
        
        LYRObjectChangeType changeType = [change[LYRObjectChangeTypeKey] integerValue];
        NSString *changedProperty = change[LYRObjectChangePropertyKey];
        
        if (changeType == LYRObjectChangeTypeUpdate && [changedProperty isEqualToString:@"metadata"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationMetadataDidChangeNotification object:changedObject];
        }
        
        if (changeType == LYRObjectChangeTypeUpdate && [changedProperty isEqualToString:@"participants"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationParticipantsDidChangeNotification object:changedObject];
        }
        
        if (changeType == LYRObjectChangeTypeDelete) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationDeletedNotification object:changedObject];
        }
    }
}

- (void)layerClient:(LYRClient *)client didFailOperationWithError:(NSError *)error
{
    NSLog(@"Layer Client did fail operation with error: %@", error);
}

- (void)layerClient:(LYRClient *)client willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit
{
    if (attemptNumber == 1) {
        //[SVProgressHUD showWithStatus:@"Connecting to Layer"];
    } else {
        //[SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Connecting to Layer in %lus (%lu of %lu)", (unsigned long)ceil(delayInterval), (unsigned long)attemptNumber, (unsigned long)attemptLimit]];
    }
}

- (void)layerClientDidConnect:(LYRClient *)client
{
    //[SVProgressHUD showSuccessWithStatus:@"Connected to Layer"];
}

- (void)layerClient:(LYRClient *)client didLoseConnectionWithError:(NSError *)error
{
    //[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Lost Connection: %@", error.localizedDescription]];
}

- (void)layerClientDidDisconnect:(LYRClient *)client
{
    //[SVProgressHUD showSuccessWithStatus:@"Disconnected from Layer"];
}

#pragma mark - Notification Handlers

- (void)didReceiveLayerClientWillBeginSynchronizationNotification:(NSNotification *)notification
{
    [self.APIManager loadContacts];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveLayerClientDidFinishSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)registerAndAuthenticateUserWithName:(NSString *)name
{
    //[self.view endEditing:YES];
    
    if (self.layerClient.authenticatedUserID) {
        NSLog(@"Layer already authenticated as: %@", self.layerClient.authenticatedUserID);
        return;
    }
    
    //[SVProgressHUD showWithStatus:@"Authenticating with Layer"];
    NSLog(@"Requesting Authentication Nonce");
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        NSLog(@"Got a nonce %@", nonce);
        if (error) {
            //ATLMAlertWithError(error);
            return;
        }
        NSLog(@"Registering user");
        /*[self.applicationController.APIManager registerUserWithName:name nonce:nonce completion:^(NSString *identityToken, NSError *error) {
         NSLog(@"User registerd and got identity token: %@", identityToken);
         if (error) {
         ATLMAlertWithError(error);
         return;
         }
         NSLog(@"Authenticating Layer");
         if (!identityToken) {
         NSError *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMInvalidIdentityToken userInfo:@{NSLocalizedDescriptionKey : @"Failed to obtain a valid identity token"}];
         ATLMAlertWithError(error);
         return;
         }
         [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
         if (error) {
         ATLMAlertWithError(error);
         return;
         }
         NSLog(@"Layer authenticated as: %@", authenticatedUserID);
         [SVProgressHUD showSuccessWithStatus:@"Authenticated!"];
         }];
         }];*/
        //https://layer-identity-provider.herokuapp.com/identity_tokens
        NSURL *identityTokenURL = [NSURL URLWithString:@"http://alanhhwong.ngrok.com/authenticate"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSDictionary *parameters = @{ @"app_id": @"188f8fcc-ca64-11e4-a5e7-eae8470048a9", @"user_id": name, @"nonce": nonce };
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        request.HTTPBody = requestBody;
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                //                completion(nil, error);
                return;
            }
            
            // Deserialize the response
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(![responseObject valueForKey:@"error"])
            {
                NSString *identityToken = responseObject[@"identity_token"];
                //                completion(identityToken, nil);
                [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                    if (error) {
                        //ATLMAlertWithError(error);
                        return;
                    }
                    NSLog(@"Layer authenticated as: %@", authenticatedUserID);
                    
//                    LYRConversation *conversation = [self conversationWithParticipants:[NSSet setWithObject:@"test3"]];
//                    
//                    ATLMConversationViewController *controller = [ATLMConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
//                    controller.conversation = conversation;
//                    [((UINavigationController *)((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController) pushViewController:controller animated:YES];
                }];
            }
            else
            {
                NSString *domain = @"layer-identity-provider.herokuapp.com";
                NSInteger code = [responseObject[@"status"] integerValue];
                NSDictionary *userInfo =
                @{
                  NSLocalizedDescriptionKey: @"Layer Identity Provider Returned an Error.",
                  NSLocalizedRecoverySuggestionErrorKey: @"There may be a problem with your APPID."
                  };
                
                NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
                //                completion(nil, error);
            }
            
        }] resume];
        
    }];
}


@end