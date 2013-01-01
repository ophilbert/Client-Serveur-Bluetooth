//
//  ViewController.m
//  Client-Serveur-Bluetooth
//
//  Created by Olivier Philbert on 11/11/12.
//  Copyright (c) 2012 Olivier Philbert. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark IBAction Method

- (IBAction)startServer:(id)sender
{
	[_server start];
	[_statutLabel setText:@"Serveur en attente de connexion"];
}

- (IBAction)listDevice:(id)sender
{
	[_client startConnection];
	[_tableview setHidden:NO];
}

- (IBAction)sendButtonPressed:(id)sender
{
	if (_server.isStart)
		[_server sendDataToAllClient:[_textField.text dataUsingEncoding:NSUTF8StringEncoding]];
	else
		[_client sendData:[_textField.text dataUsingEncoding:NSUTF8StringEncoding]];
}

- (IBAction)disconnect:(id)sender
{
	if (_server.isStart)
		[_server stop];
	else
		[_client disconnect];
	[_disconnectButton setHidden:YES];
	[_statutLabel setText:@"Non connecté"];
}

#pragma mark - Server Delegate

- (void)serverAccept:(HSocket *)socket
{
	[_statutLabel setText:[NSString stringWithFormat:@"Connecté en tant que serveur avec %d devices", [_server.clients count]]];
	
	[_chatView setHidden:NO];
	[_textField setHidden:NO];
	[_sendButton setHidden:NO];
	[_disconnectButton setHidden:NO];
}

- (void)server:(Server *)server didReceiveData:(NSData *)data
{
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[_chatView setText:[_chatView.text stringByAppendingFormat:@"\n%@", str]];
	[str release];
}

#pragma mark - Client Delegate

- (void)client:(Client *)client didFindDevice:(NSString *)deviceName
{
	NSLog(@"Did find device named %@", deviceName);
}

- (void)client:(Client *)client didGetAllAvailableDevices:(NSArray *)availableDevices
{
	_devices = [[NSMutableArray alloc] initWithArray:availableDevices];
	[_tableview reloadData];
}

- (void)client:(Client *)client didReceiveData:(NSData *)data
{
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[_chatView setText:[_chatView.text stringByAppendingFormat:@"\n%@", str]];
	[str release];
}

- (void)client:(Client *)client didStopWithError:(NSError *)error
{
	NSLog(@"Client stop with error");
}

- (void)clientDidConnectToServer:(Client *)client
{
	[_statutLabel setText:@"Connecté en tant que client"];
	[_tableview setHidden:YES];
	
	[_chatView setHidden:NO];
	[_textField setHidden:NO];
	[_sendButton setHidden:NO];
	[_disconnectButton setHidden:NO];
}

- (void)clientDidStartBrowsingForDevice:(Client *)client
{
	[_statutLabel setText:@"Recherche de devices en cours"];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_devices)
		return [_devices count];
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellId = @"CellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
	}
	Device *device = [_devices objectAtIndex:indexPath.row];
	[cell.textLabel setText:device.name];
	return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Device *d = [_devices objectAtIndex:indexPath.row];
	[_client connectToDevice:d];
}

#pragma mark UIViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	_server = [[Server alloc]initWithPort:8888];
	[_server setDelegate:self];
	
	_client = [[Client alloc]init];
	[_client setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[_devices release];
	[_client release];
	[_server release];
	[super dealloc];
}

@end
