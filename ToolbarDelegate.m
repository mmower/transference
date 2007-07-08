//
//  ToolbarDelegate.m
//  Transference
//
//  Created by Matt Mower on 02/07/2007.
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

#import "BrowserController.h"
#import "ToolbarDelegate.h"

@implementation BrowserController (ToolbarDelegate)

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	if( [itemIdentifier isEqualToString:@"Follow"] ) {
		[item setLabel:@"Follow"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Folder Follow"]];
		[item setTarget:self];
		[item setAction:@selector(targetFollowsSource:)];
	} else if( [itemIdentifier isEqualToString:@"Switch"] ) {
		[item setLabel:@"Switch"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Folder Switch"]];
		[item setTarget:self];
		[item setAction:@selector(switchSourceAndTarget:)];
	} else if( [itemIdentifier isEqualToString:@"Copy"] ) {
		[item setLabel:@"Copy"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Copy Files"]];
		[item setTarget:self];
		[item setAction:@selector(copyFiles:)];
	} else if( [itemIdentifier isEqualToString:@"Move"] ) {
		[item setLabel:@"Move"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Move Files"]];
		[item setTarget:self];
		[item setAction:@selector(moveFiles:)];
	} else if( [itemIdentifier isEqualToString:@"Select"] ) {
		[item setLabel:@"Select"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Add"]];
		[item setTarget:self];
		[item setAction:@selector(checkSelectedFiles:)];
	} else if( [itemIdentifier isEqualToString:@"Deselect"] ) {
		[item setLabel:@"Deselect"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Remove"]];
		[item setTarget:self];
		[item setAction:@selector(uncheckSelectedFiles:)];
	} else if( [itemIdentifier isEqualToString:@"Refresh"] ) {
		[item setLabel:@"Refresh"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Refresh"]];
		[item setTarget:self];
		[item setAction:@selector(refreshFiles:)];
	} else if( [itemIdentifier isEqualToString:@"Root"] ) {
		[item setLabel:@"Root"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Root"]];
		[item setTarget:self];
		[item setAction:@selector(browseRoot:)];
	} else if( [itemIdentifier isEqualToString:@"Home"] ) {
		[item setLabel:@"Home"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Home"]];
		[item setTarget:self];
		[item setAction:@selector(browseHome:)];
	} else if( [itemIdentifier isEqualToString:@"Up"] ) {
		[item setLabel:@"Up"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Up"]];
		[item setTarget:self];
		[item setAction:@selector(browseParent:)];
	} else if( [itemIdentifier isEqualToString:@"Back"] ) {
		[item setLabel:@"Back"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"SnapBack"]];
		[item setTarget:self];
		[item setAction:@selector(browseBack:)];
	}
			
    return [item autorelease];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier,
		@"Follow",
		@"Switch",
		@"Copy",
		@"Move",
		@"Select",
		@"Deselect",
		@"Refresh",
		@"Up",
		@"Back",
		@"Root",
		@"Home",
		nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:@"Refresh",
		NSToolbarFlexibleSpaceItemIdentifier,
		@"Root",
		@"Home",
		@"Up",
		@"Back",
		@"Follow",
		@"Switch",
		NSToolbarFlexibleSpaceItemIdentifier,
		@"Select",
		@"Deselect",
		NSToolbarFlexibleSpaceItemIdentifier,
		@"Copy",
		@"Move",
		NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier,
		nil];
}


@end
