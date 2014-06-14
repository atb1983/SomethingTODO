//
//  STDSettingsViewController.m
//  SomethingTODO
//
//  Created by Alex Núñez on 14/06/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "STDSettingsViewController.h"
#import "STDConst.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

typedef NS_ENUM(NSUInteger, CellSectionType) {
    CellSectionTypeSupport,
    CellSectionTypeAbout,
};

typedef NS_ENUM(NSUInteger, CellSupportType) {
	CellSupportTypeFeedBack,
};

typedef NS_ENUM(NSUInteger, CellAboutType) {
	CellAboutTypeShare,
    CellAboutTypeReview,
	CellAboutTypeAbout
};

@interface STDSettingsViewController () <MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *supportEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;

@end

@implementation STDSettingsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"settings_title_vc", nil);
	self.supportEmailLabel.text = NSLocalizedString(@"settings_support_cell", nil);
	self.shareLabel.text = NSLocalizedString(@"settings_share_cell", nil);
	self.reviewLabel.text = NSLocalizedString(@"settings_review_cell", nil);
	self.aboutLabel.text = NSLocalizedString(@"settings_about_cell", nil);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case CellSectionTypeSupport:
			
			switch (indexPath.row) {
				case CellSupportTypeFeedBack:
					[self sendSupportEmail];
					break;
			}
			
			break;
			
		case CellSectionTypeAbout:
			
			switch (indexPath.row) {
				case CellAboutTypeShare:
					[self showTellfriendsActionSheet];
					break;
				case CellAboutTypeReview:
					[self showAppStoreReviewPage];
					break;
				case CellAboutTypeAbout:
					[self showAbout];
					break;
			}
			
			break;
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = nil;
	
    if (section == CellSectionTypeAbout)
	{
        // This UIView will only be created for the last section of your UITableView
        footerView = [[UIView alloc] initWithFrame:CGRectZero];
		footerView.backgroundColor = [UIColor clearColor];
		footerView.opaque = NO;
		
		UILabel *label = [[UILabel alloc] init];
		label.frame = CGRectMake(15, 10, self.tableView.bounds.size.width - 30, 18);
		label.textAlignment = NSTextAlignmentCenter;
		label.text = [self appVersionNumberDisplayString];
		label.font = [UIFont systemFontOfSize:15.0];
		[footerView addSubview:label];
    }
	
    return footerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == CellSectionTypeSupport)
	{
		return NSLocalizedString(@"settings_support_header", nil);
	}
	
	return nil;
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:
		{
			[self sendEmailToAFriend];
			break;
		}
		case 1:
		{
			[self shareToFacebook];
			break;
		}
		case 2:
		{
			[self shareToTwitter];
			break;
		}
		default:
		{
			break;
		}
	}
}

- (void)sendSupportEmail
{
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
		mailComposeViewController.mailComposeDelegate = self;
		[mailComposeViewController setSubject:NSLocalizedString(@"support_mail_subject", nil)];
		[mailComposeViewController setToRecipients:@[kSomethingTodoSpportEmailAddress]];
		
		// Fill out the email body text
		
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		NSString *model = [[UIDevice currentDevice] model];
		NSString *searcleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
		
		NSString *emailBody = [NSString stringWithFormat:@"%@\n\n----------------------------------\niOS Version: %@\nModel: %@\nApp Version: %@\n----------------------------------",
							   NSLocalizedString(@"support_mail_body", nil),
							   currSysVer,
							   model,
							   searcleVersion];
		[mailComposeViewController setMessageBody:emailBody isHTML:NO];
		
		[self presentViewController:mailComposeViewController animated:YES completion:nil];
	}
	else
	{
		[self showAlertViewNoEmailAccount];
	}
}

- (void)sendEmailToAFriend
{
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
		mailComposeViewController.mailComposeDelegate = self;
		[mailComposeViewController setSubject:NSLocalizedString(@"tell_a_friend_email_subject", nil)];
		[mailComposeViewController setMessageBody:NSLocalizedString(@"tell_a_friend_email_body", nil) isHTML:NO];
		
		[self presentViewController:mailComposeViewController animated:YES completion:nil];
	}
	else
	{
		[self showAlertViewNoEmailAccount];
	}
}

- (void)showAlertViewForNoEmailAccounts
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"settings_alert_message_no_email_account", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
	[alertView show];
}

- (void)shareToFacebook
{
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:NSLocalizedString(@"share_facebook_title", nil)];
		[composeViewController addURL:[NSURL URLWithString:kSomethingTodoAppStore]];
		
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
	else
	{
		[self showAlertViewNoFacebookAccount];
	}
}

- (void)shareToTwitter
{
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:NSLocalizedString(@"share_twitter_title", nil)];
		[composeViewController addURL:[NSURL URLWithString:kSomethingTodoAppStore]];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
	else
	{
		[self showAlertViewNoTwitterAccount];
	}
}

- (void)showAppStoreReviewPage
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kSomethingTodoAppStore]];
}

- (void)showAbout
{
	NSMutableString *message = [[NSMutableString alloc] initWithString:@"Something ToDo \n"];
	[message appendString:NSLocalizedString(@"about_message", nil)];
	[message appendString:@"\n\n"];
	[message appendString:[self appVersionNumberDisplayString]];
	[message appendString:@"\n\n"];
	[message appendFormat:NSLocalizedString(@"about_licence", nil), @"VisualPharm", @"http://www.visualpharm.com/"];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"about_about_me", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"common_ok",nil) otherButtonTitles:nil, nil];
	[alertView show];
}

- (NSString *)appVersionNumberDisplayString
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *shortBundleVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
	
    return [NSString stringWithFormat:@"%@ %@ - %@", NSLocalizedString(@"settings_version", nil), shortBundleVersion, @__DATE__];
}

#pragma mark - Alerts and ActionSheets

- (void)showTellfriendsActionSheet
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Facebook", @"Twitter", nil, nil];
	[actionSheet showInView:self.view];
}

- (void)showAlertViewNoEmailAccount
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"settings_alert_message_no_email_account", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
	[alertView show];
}

- (void)showAlertViewNoFacebookAccount
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"settings_alert_message_no_facebook_account", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
	[alertView show];
}

- (void)showAlertViewNoTwitterAccount
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"settings_alert_message_no_twitter_account", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"common_ok", nil) otherButtonTitles:nil, nil];
	[alertView show];
}


@end
