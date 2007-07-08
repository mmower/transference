//
//  FileBrowserTableView.m
//  Transference
//
//  Created by Matt Mower on 01/07/2007.
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

//
// Originally we tried to do the custom key-down handling via a category replacement
// of keyDown: and delegation however it then became difficult (if not impossible) to
// get the original table keyboard handling back.
//

#import "FileBrowserTableView.h"
#import "FileBrowserTableViewDelegates.h"

#import "FileWrapper.h"

@implementation FileBrowserTableView

- (unichar)keyFromEvent:(NSEvent *)__event
{
	if( [[__event characters] length] < 1 ) {
		return 0;
	} else {
		return [[__event characters] characterAtIndex:0];
	}
}

- (void)keyDown:(NSEvent *)__event
{
	switch( [self keyFromEvent:__event] ) {
		case 0x2A:
			[self selectNextRow];
			break;
			
		case 0x2B: // +
			[self checkSelected];
			break;
			
		case 0x2D: // -
			[self uncheckSelected];
			break;
			
		case 0x20: // SPACE
			[self drillDownSelected];
			break;
			
		case 0x03: // ENTER
			[self toggleSelected];
			break;
			
		default:
			//NSLog( @"%02x", [self keyFromEvent:__event] );
			[super keyDown:__event];
	}
}

- (void)checkSelected
{
	NSIndexSet *indexes = [self selectedRowIndexes];
	 
	int index = [indexes firstIndex];
	while( index != NSNotFound ) {
		[[self fileForRow:index] setSelected:YES];
		index = [indexes indexGreaterThanIndex:index];
	}
	
	[self selectNextRow];
}

- (void)uncheckSelected
{
	NSIndexSet *indexes = [self selectedRowIndexes];
	
	int index = [indexes firstIndex];
	while( index != NSNotFound ) {
		[[self fileForRow:index] setSelected:NO];
		index = [indexes indexGreaterThanIndex:index];
	}
	
	[self selectNextRow];
}

- (void)toggleSelected
{
	NSIndexSet *indexes = [self selectedRowIndexes];
	
	int index = [indexes firstIndex];
	while( index != NSNotFound ) {
		FileWrapper *file = [self fileForRow:index];
		[file setSelected:![file selected]];
		
		index = [indexes indexGreaterThanIndex:index];
	}
	
	[self selectNextRow];
}

- (void)drillDownSelected
{
	if( [[self delegate] respondsToSelector:@selector(drillDownBrowserTable:atRow:)] ) {
		return [[self delegate] drillDownBrowserTable:self atRow:[self selectedRow]];
	}
}

- (void)selectNextRow
{
	NSIndexSet *indexes = [self selectedRowIndexes];
	
	if( [indexes count] == 1 ) {
		[self selectRow:[indexes firstIndex]+1 byExtendingSelection:NO];
	}
}

- (FileWrapper *)fileForRow:(int)__rowIndex
{
	if( [[self delegate] respondsToSelector:@selector(fileFromBrowserTable:atRow:)] ) {
		return [[self delegate] fileFromBrowserTable:self atRow:__rowIndex];
	} else {
		return nil;
	}
}

@end
