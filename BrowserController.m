//
//  BrowserController.m
//  Transference
//
//  Created by Matt Mower on 29/06/2007.
//  Copyright (c) 2007 Matt Mower
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  Except as contained in this notice, the name(s) of the above
//  copyright holders shall not be used in advertising or otherwise
//  to promote the sale, use or other dealings in this Software
//  without prior written authorization.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "FileWrapper.h"
#import "FileBrowserTableView.h"

#import "BrowserController.h"

#import "Tsai.h"

#import "Preferences.h"
#import "NSFileManager+Utilities.h"

NSString *TransferenceSourcePath = @"SourcePath";
NSString *TransferenceSourceHistory = @"SourceHistory";
NSString *TransferenceTargetPath = @"TargetPath";
NSString *TransferenceTargetHistory = @"TargetHistory";

@implementation BrowserController

#pragma mark -
#pragma mark Lifecycle
+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:NSHomeDirectory() forKey:TransferenceSourcePath];
	[defaultValues setObject:NSHomeDirectory() forKey:TransferenceTargetPath];
	[defaultValues setObject:[[NSArray alloc] init] forKey:TransferenceSourceHistory];
	[defaultValues setObject:[[NSArray alloc] init] forKey:TransferenceTargetHistory];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (id)init
{
	if( ( self = [super init]) != nil )
	{
	}
	return self;
}

- (void)dealloc
{
	[fileCompletionTextViewDelegate release];
	
	[sourceFiles release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[[NSApplication sharedApplication] setDelegate:self];
	
	[sourceFileTable setDoubleAction:@selector(browseIntoSource:)];
	[targetFolderTable setDoubleAction:@selector(drillDownTarget:)];
	
	[self setSourcePath:[[NSUserDefaults standardUserDefaults] stringForKey:TransferenceSourcePath]];
	[self setTargetPath:[[NSUserDefaults standardUserDefaults] stringForKey:TransferenceTargetPath]];
	[sourcePathField addItemsWithObjectValues:[[NSUserDefaults standardUserDefaults] arrayForKey:TransferenceSourceHistory]];
	[targetPathField addItemsWithObjectValues:[[NSUserDefaults standardUserDefaults] arrayForKey:TransferenceTargetHistory]];
		
	toolbar = [[NSToolbar alloc] initWithIdentifier:@"toolbar"];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	[toolbar setDelegate:self];
	[appWindow setToolbar:toolbar];
}

#pragma mark -
#pragma KVC validation

- (BOOL)validateValue:(id *)__value forKeyPath:(NSString *)__path error:(NSError **)__error
{
	if( [__path isEqualToString:@"sourcePath"] || [__path isEqualToString:@"targetPath"] ) {
		BOOL folder, exists;
		
		exists = [[NSFileManager defaultManager] fileExistsAtPath:*__value isDirectory:&folder];
		
		if( !exists ) {
			*__error = [[[NSError alloc] initWithDomain:@": No such folder exists" code:1 userInfo:nil] autorelease];
		} else if( !folder ) {
			*__error = [[[NSError alloc] initWithDomain:@": Is not a folder" code:2 userInfo:nil] autorelease];
		}
		
		return exists && folder;
	} else {
		return YES;
	}
}

#pragma mark -
#pragma Source browser

- (NSString *)sourcePath
{
	return sourcePath;
}

- (void)setSourcePath:(NSString *)__path
{
	[self willChangeValueForKey:@"sourcePath"];
	
	if( sourcePath != nil ) {
		if( [sourcePathField indexOfItemWithObjectValue:sourcePath] != NSNotFound ) {
			[sourcePathField removeItemWithObjectValue:sourcePath];
		}
		[sourcePathField insertItemWithObjectValue:sourcePath atIndex:0];
	}
	
	[sourcePath release];
	sourcePath = [[__path stringByExpandingTildeInPath] copy];
	
	[self updateSourceFiles];
		
	[self didChangeValueForKey:@"sourcePath"];	
	[self updateIntent];
}

- (void)updateSourceFiles
{
	[self willChangeValueForKey:@"sourceFiles"];
	[sourceFiles release];
	sourceFiles = [FileWrapper filesForPath:[self sourcePath] filter:nil];
//	sourceFiles = [FileWrapper filesForPath:[self sourcePath]];
	[self didChangeValueForKey:@"sourceFiles"];
}

- (NSArray *)sourceFilesForAction
{
	return [[sourceFilesController arrangedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = true", @"selected"]];
}

#pragma mark -
#pragma Target browser

- (NSString *)targetPath
{
	return targetPath;
}

- (NSString *)destinationPath
{
	if( [targetFolderTable selectedRow] == -1 ) {
		return targetPath;
	} else {
		return [[[targetFoldersController arrangedObjects] objectAtIndex:[targetFolderTable selectedRow]] path];
	}
}

- (void)setTargetPath:(NSString *)__path
{
	[self willChangeValueForKey:@"targetPath"];
	
	if( targetPath != nil ) {
		if( [targetPathField indexOfItemWithObjectValue:targetPath] != NSNotFound ) {
			[targetPathField removeItemWithObjectValue:targetPath];
		}
		[targetPathField insertItemWithObjectValue:targetPath atIndex:0];
	}
	
	[targetPath autorelease];
	targetPath = [[__path stringByExpandingTildeInPath] copy];

	[targetFolderTable deselectAll:self];
	[self updateTargetFolders];
	
	[self didChangeValueForKey:@"targetPath"];	
	[self updateIntent];
}

- (void)updateTargetFolders
{
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = true", @"isFolder"];
	
	[self willChangeValueForKey:@"targetFolders"];
	[targetFolders release];
	targetFolders = [FileWrapper filesForPath:[self targetPath] filter:filter];
	[self didChangeValueForKey:@"targetFolders"];
}

- (IBAction)setDestination:(id)__sender
{
	[self updateIntent];
}

- (void)updateIntent
{
	if( [self sourcePath] != nil && [self targetPath] != nil ) {
		[intentField setStringValue:[NSString stringWithFormat:@"Transfer from:  %@  -->  %@", [self sourcePath], [self destinationPath]]];
	}	
}

- (IBAction)refreshFiles:(id)__sender
{
	[self updateSourceFiles];
	[self updateTargetFolders];
}

#pragma mark -
#pragma mark Quick selectors

typedef enum {
	unknownPane,
	sourcePane,
	targetPane
} BrowserPaneId;

- (BrowserPaneId)detectSelectedBrowser
{
	if( [appWindow firstResponder] == sourceFileTable ) {
		return sourcePane;
	} else if( [appWindow firstResponder] == targetFolderTable ) {
		return targetPane;
	} else if( [[[appWindow firstResponder] class] isEqual:[NSTextView class]] ) {
		NSTextView *view = (NSTextView *)[appWindow firstResponder];
		if( [view delegate] == sourcePathField ) {
			return sourcePane;
		} else if( [view delegate] == targetPathField ) {
			return targetPane;
		} else {
			return unknownPane;
		}
	} else {
		return unknownPane;
	}
}

- (IBAction)browseRoot:(id)__sender
{
	switch( [self detectSelectedBrowser] ) {
		case sourcePane:
			[self setSourcePath:@"/"];
			break;
			
		case targetPane:
			[self setTargetPath:@"/"];
			break;
	}
}

- (IBAction)browseHome:(id)__sender
{
	switch( [self detectSelectedBrowser] ) {
		case sourcePane:
			[self setSourcePath:NSHomeDirectory()];
			break;
			
		case targetPane:
			[self setTargetPath:NSHomeDirectory()];
			break;
	}
}

- (IBAction)browseBack:(id)__sender
{
	switch( [self detectSelectedBrowser] ) {
		case sourcePane:
			if( [sourcePathField numberOfItems] > 0 ) {
				[self setSourcePath:[sourcePathField itemObjectValueAtIndex:0]];
			}
			break;
			
		case targetPane:
			if( [targetPathField numberOfItems] > 0 ) {
				[self setTargetPath:[targetPathField itemObjectValueAtIndex:0]];
			}
			break;
	}
}

- (IBAction)browseParent:(id)__sender
{
	switch( [self detectSelectedBrowser] ) {
		case sourcePane:
			[self setSourcePath:[[NSFileManager defaultManager] parentPath:[self sourcePath]]];
			break;
			
		case targetPane:
			[self setTargetPath:[[NSFileManager defaultManager] parentPath:[self targetPath]]];
			break;
	}
}

#pragma mark -
#pragma mark Creating new folders

- (IBAction)newFolderInTarget:(id)__sender
{
	[NSApp beginSheet:newFolderWindow
	   modalForWindow:appWindow
		modalDelegate:self 
	   didEndSelector:@selector(newFolderSheetEnded:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (IBAction)newFolderCreate:(id)__sender
{
	[newFolderWindow orderOut:__sender];
	[NSApp endSheet:newFolderWindow returnCode:YES];
}

- (IBAction)newFolderCancel:(id)__sender
{
	[newFolderWindow orderOut:__sender];
	[NSApp endSheet:newFolderWindow returnCode:NO];
}

- (void)newFolderSheetEnded:(NSWindow *)__sheet returnCode:(int)__returnCode contextInfo:(void *)__contextInfo
{
	if( __returnCode == YES ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:[[self targetPath] stringByAppendingPathComponent:[newFolderNameField stringValue]] attributes:nil];
		[self updateTargetFolders];
	}
}

#pragma mark -
#pragma mark Application Delegate

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	[self setSourcePath:filename];
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)__sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[self sourcePath] forKey:TransferenceSourcePath];
	[[NSUserDefaults standardUserDefaults] setObject:[self targetPath] forKey:TransferenceTargetPath];
	[[NSUserDefaults standardUserDefaults] setObject:[sourcePathField objectValues] forKey:TransferenceSourceHistory];
	[[NSUserDefaults standardUserDefaults] setObject:[targetPathField objectValues] forKey:TransferenceTargetHistory];
	
	return NSTerminateNow;
}


#pragma mark -
#pragma mark Table Delegate

- (FileWrapper *)fileFromBrowserTable:(FileBrowserTableView *)__view atRow:(int)__rowIndex
{
	if( __view == sourceFileTable ) {
		return (FileWrapper *)[[sourceFilesController arrangedObjects] objectAtIndex:__rowIndex];
	} else {
		return nil;
	}
}

- (void)drillDownBrowserTable:(FileBrowserTableView *)__view atRow:(int)__rowIndex
{
	if( __view == sourceFileTable ) {
		FileWrapper *file = [[sourceFilesController arrangedObjects] objectAtIndex:__rowIndex];	
		if( [file isFolder] ) {
			[self setSourcePath:[file path]];
		}
	}
}

#pragma mark -
#pragma mark File Actions

- (IBAction)chooseSourcePath:(id)__sender
{
	NSString *path = [self selectFolder:@"Select Source"];
	if( path != nil ) {
		[self setSourcePath:path];
	}
}

- (IBAction)chooseTargetPath:(id)__sender
{
	NSString *path = [self selectFolder:@"Select Destination"];
	if( path != nil ) {
		[self setTargetPath:path];
	}
}

- (IBAction)targetFollowsSource:(id)__sender
{
	[self setTargetPath:[self sourcePath]];
}

- (IBAction)switchSourceAndTarget:(id)__sender
{
	NSString *path = [self sourcePath];
	[self setSourcePath:[self targetPath]];
	[self setTargetPath:path];
}

- (IBAction)browseIntoSource:(id)__sender
{
	[self drillDownBrowserTable:sourceFileTable atRow:[sourceFileTable selectedRow]];
}

- (IBAction)drillDownTarget:(id)__sender
{
	[self setTargetPath:[self destinationPath]];
}

- (NSString *)selectFolder:(NSString *)purpose
{
	NSOpenPanel* browser = [NSOpenPanel openPanel];
	
	[browser setCanChooseFiles:NO];
	[browser setCanChooseDirectories:YES];
	[browser setPrompt:purpose];
	[browser setAllowsMultipleSelection:NO];
	if( [browser runModal] != NSCancelButton )
	{
		return [[browser filenames] objectAtIndex:0];
	} else {
		return nil;
	}
}

- (IBAction)checkSelectedFiles:(id)__sender
{
	[sourceFileTable checkSelected];
}

- (IBAction)uncheckSelectedFiles:(id)__sender
{
	[sourceFileTable uncheckSelected];
}

#pragma mark -
#pragma mark Copy & Move actions

- (IBAction)copyFiles:(id)__sender
{
	NSLog( @"copyFiles:" );
	[NSApp beginSheet:activityWindow
	   modalForWindow:appWindow
		modalDelegate:self
	   didEndSelector:@selector(activitySheetEnded:returnCode:contextInfo:)
		  contextInfo:nil];
	
	[activityMeter startAnimation:self];
	copyMoveCancelled = NO;
	[NSThread detachNewThreadSelector:@selector(backgroundCopy:) toTarget:self withObject:nil];
}

- (void)finishedCopy
{
	[self cancelCopyMove:self];
}

- (void)backgroundCopy:(id)__arg
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self copyFiles:[self sourceFilesForAction] toPath:[self destinationPath]];
	[self cancelCopyMove:self];
	[pool release];
	[self performSelectorOnMainThread:@selector(finishedCopy) withObject:nil waitUntilDone:YES];
}

- (void)copyFiles:(NSArray *)__files toPath:(NSString *)__path
{
	foreach( file, __files ) {
		if( copyMoveCancelled ) {
			break;
		}
		copyMoveCancelled = ![self copyFile:file toPath:__path];
	}
}

- (BOOL)copyFile:(FileWrapper *)__file toPath:(NSString *)__path
{
	[activityMessage setStringValue:[NSString stringWithFormat:@"Copying %@", [__file name]]];
	BOOL success = [[NSFileManager defaultManager] copyPath:[__file path] toPath:[self makeTarget:__file withPath:__path] handler:self];
	return success;
}

- (IBAction)moveFiles:(id)__sender
{
	NSLog( @"moveFiles:" );
	[NSApp beginSheet:activityWindow
	   modalForWindow:appWindow
		modalDelegate:self
	   didEndSelector:@selector(activitySheetEnded:returnCode:contextInfo:)
		  contextInfo:nil];
	
	[activityMeter startAnimation:self];
	copyMoveCancelled = NO;
	[NSThread detachNewThreadSelector:@selector(backgroundMove:) toTarget:self withObject:nil];
}

- (void)finishedMove
{
	[self cancelCopyMove:self];

	// Trigger an update since some files will now be gone
	[self setSourcePath:[self sourcePath]];
}

- (void)backgroundMove:(id)__arg
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self moveFiles:[self sourceFilesForAction] toPath:[self destinationPath]];
	[pool release];
	[self performSelectorOnMainThread:@selector(finishedMove) withObject:nil waitUntilDone:YES];
}

- (void)moveFiles:(NSArray *)__files toPath:(NSString *)__path
{
	foreach( file, __files ) {
		if( copyMoveCancelled ) {
			break;
		}
		copyMoveCancelled = ![self moveFile:file toPath:__path];
	}
}

- (BOOL)moveFile:(FileWrapper *)__file toPath:(NSString *)__path
{
	[activityMessage setStringValue:[NSString stringWithFormat:@"Moving %@", [__file name]]];
	
	BOOL success = YES;

	// We must delete any existing file
	if( [[NSFileManager defaultManager] fileExistsAtPath:[self makeTarget:__file withPath:__path]] ) {
		success = [[NSFileManager defaultManager] removeFileAtPath:[self makeTarget:__file withPath:__path] handler:self];
	}
	
	// If there was no existing file, or problem deleting one go ahead
	if( success ) {
		success = [[NSFileManager defaultManager] movePath:[__file path] toPath:[self makeTarget:__file withPath:__path] handler:self];
	}
	
	NSLog( @"Moved %@ (%@)", [__file name], success ? @"YES" : @"NO" );
	return success;
}

- (NSString *)makeTarget:(FileWrapper *)__file withPath:(NSString *)__path
{
	return [__path stringByAppendingPathComponent:[__file name]];
}

- (void)fileManager:(NSFileManager *)__manager willProcessPath:(NSString *)__path
{
}

- (BOOL)fileManager:(NSFileManager *)__manager shouldProceedAfterError:(NSDictionary *)__errorInfo
{
    int result = NSRunAlertPanel(
							@"Transference",
							@"File operation error: %@ with file: %@",
							@"Proceed",
							@"Stop",
							NULL,
							[__errorInfo objectForKey:@"Error"],
							[__errorInfo objectForKey:@"Path"]
							);
	
    if( result == NSAlertDefaultReturn ) {
		return YES;
	} else {
        return NO;
	}
}

// Sheet Delegate

- (void)activityStart
{
}

- (void)activitySheetEnded:(NSWindow*)__sheet returnCode:(int)__code contextInfo:(void*)__contextInfo
{
	[activityMeter stopAnimation:self];
}

- (IBAction)cancelCopyMove:(id)__sender
{
	copyMoveCancelled = YES;
	[NSApp endSheet:activityWindow];
	[activityWindow orderOut:__sender];
}

#pragma mark -
#pragma mark Search Action

- (void)setSearchFilter:(NSString *)__filter
{
	if( [__filter isEqualToString:@""] ) {
		[sourceFilesController setFilterPredicate:nil];
	} else {
		NSString *attributeName = @"name";
		NSPredicate* filterPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", attributeName, __filter];
/*		NSLog( @"Setting filter predicate to %@", [filterPredicate predicateFormat] );*/
		[sourceFilesController setFilterPredicate:filterPredicate];
	}
}

- (IBAction)search:(id)__sender
{
	NSString* searchTerm = [__sender stringValue];
	[self setSearchFilter:searchTerm];
}

@end
