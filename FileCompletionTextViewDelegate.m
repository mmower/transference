//
//  FileCompletionTextViewDelegate.m
//  Transference
//
//  Created by Matt Mower on 07/07/2007.
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


#import "FileCompletionTextViewDelegate.h"

#import "Tsai.h"

@implementation FileCompletionTextViewDelegate

- (NSArray *)control:(NSControl *)__control textView:(NSTextView *)__view completions:(NSArray *)__words forPartialWordRange:(NSRange)__range indexOfSelectedItem:(int *)__index
{
	BOOL folder;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// If the string is a path, attempt to complete
	NSString *userPath = [__view string];
	
	NSArray *components = [userPath pathComponents];
    NSArray *componentsBase;
	
	folder = NO;
	[fileManager fileExistsAtPath:userPath isDirectory:&folder];
	
    // get our search directory, described by componentsBase
    if( [components count] > 1 && !folder )
    {
        componentsBase = [components subarrayWithRange:NSMakeRange(0, [components count] - 1)];
    }
    else
    {
        componentsBase = components;
    }
	
	NSString *basePath = [[NSString pathWithComponents:componentsBase] stringByExpandingTildeInPath];
	
    NSArray *dirContents = [fileManager directoryContentsAtPath:basePath];
	
	NSMutableArray *completions = [[NSMutableArray alloc] initWithCapacity:[dirContents count]];
	NSString *completedPath;
	
	foreach( path, dirContents ) {
		completedPath = [[NSString pathWithComponents:componentsBase] stringByAppendingPathComponent:path];
		
		folder = NO;
		[fileManager fileExistsAtPath:completedPath isDirectory:&folder];
		
		if( [[completedPath lowercaseString] hasPrefix:[userPath lowercaseString]] && folder ) {
			[completions addObject:[completedPath substringFromIndex:__range.location]];
		}
	}
	
	return completions;
}

@end
