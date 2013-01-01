//
//  ViewController.h
//  Client-Serveur-Bluetooth
//
//  Created by Olivier Philbert on 11/11/12.
//  Copyright (c) 2012 Olivier Philbert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Server.h"
#import "Client.h"

@interface ViewController : UIViewController <ServerDelegate, ClientDelegate, UITableViewDataSource, UITableViewDelegate>
{
	IBOutlet UILabel *_statutLabel;
	IBOutlet UITableView *_tableview;
	
	IBOutlet UITextView *_chatView;
	IBOutlet UITextField *_textField;
	IBOutlet UIButton *_sendButton;
	IBOutlet UIButton *_disconnectButton;
	
	Server *_server;
	Client *_client;

	NSMutableArray *_devices;
}


- (IBAction)startServer:(id)sender;
- (IBAction)listDevice:(id)sender;
- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)disconnect:(id)sender;
@end
