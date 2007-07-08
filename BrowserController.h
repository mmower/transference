//
//  BrowserController.h
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

#import <Cocoa/Cocoa.h>

#import "FileWrapper.h"
#import "FileBrowserTableView.h"
#import "FileCompletionTextViewDelegate.h"

@interface BrowserController : NSObject {
	NSArray							*sourceFiles;
	NSString						*sourcePath;

	IBOutlet NSSearchField			*sourceSearchField;
	IBOutlet NSComboBox				*sourcePathField;
	IBOutlet FileBrowserTableView	*sourceFileTable;
	IBOutlet NSArrayController		*sourceFilesController;

	NSArray							*targetFolders;
	NSString						*targetPath;
	
	IBOutlet NSComboBox				*targetPathField;
	IBOutlet NSTableView			*targetFolderTable;
	IBOutlet NSArrayController		*targetFoldersController;
	
	IBOutlet NSTextField			*intentField;
	
	IBOutlet NSToolbar				*toolbar;
	
	IBOutlet NSWindow				*appWindow;
	
	BOOL							copyMoveCancelled;
	IBOutlet NSWindow				*activityWindow;
	IBOutlet NSTextField			*activityMessage;
	IBOutlet NSProgressIndicator	*activityMeter;
	IBOutlet NSButton				*activityCancelButton;
	
	IBOutlet NSWindow				*newFolderWindow;
	IBOutlet NSTextField			*newFolderNameField;
	
	FileCompletionTextViewDelegate	*fileCompletionTextViewDelegate;
}

- (NSString *)sourcePath;
- (void)setSourcePath:(NSString *)path;
- (void)updateSourceFiles;
- (NSArray *)sourceFilesForAction;

- (NSString *)targetPath;
- (NSString *)destinationPath;
- (void)setTargetPath:(NSString *)path;
- (void)updateTargetFolders;

- (IBAction)setDestination:(id)sender;
- (void)updateIntent;

- (void)setSearchFilter:(NSString *)filter;
- (IBAction)search:(id)sender;

- (IBAction)chooseSourcePath:(id)sender;
- (IBAction)chooseTargetPath:(id)sender;
- (IBAction)targetFollowsSource:(id)sender;
- (IBAction)switchSourceAndTarget:(id)sender;

- (IBAction)browseRoot:(id)sender;
- (IBAction)browseHome:(id)sender;
- (IBAction)browseBack:(id)sender;
- (IBAction)browseParent:(id)sender;

- (IBAction)browseIntoSource:(id)sender;
- (IBAction)drillDownTarget:(id)sender;

- (IBAction)newFolderInTarget:(id)sender;
- (IBAction)newFolderCreate:(id)sender;
- (IBAction)newFolderCancel:(id)sender;

- (IBAction)refreshFiles:(id)sender;

- (NSString *)selectFolder:(NSString *)purpose;

- (IBAction)checkSelectedFiles:(id)sender;
- (IBAction)uncheckSelectedFiles:(id)sender;

- (void)backgroundCopy:(id)arg;
- (IBAction)copyFiles:(id)sender;
- (void)copyFiles:(NSArray *)files toPath:(NSString *)path;
- (BOOL)copyFile:(FileWrapper *)file toPath:(NSString *)path;

- (void)backgroundMove:(id)arg;
- (IBAction)moveFiles:(id)sender;
- (void)moveFiles:(NSArray *)files toPath:(NSString *)path;
- (BOOL)moveFile:(FileWrapper *)file toPath:(NSString *)path;

- (NSString *)makeTarget:(FileWrapper *)file withPath:(NSString *)path;
- (IBAction)cancelCopyMove:(id)sender;

@end
