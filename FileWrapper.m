//
//  FileWrapper.m
//  Transference
//
//  Created by Matt Mower on 30/06/2007.
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

#import "Tsai.h"
#import "NSFileManager+Utilities.h"

@implementation FileWrapper

+ (NSArray *)filesForPath:(NSString *)__path
{
	NSString *contentPath;
	NSMutableArray *files = [[NSMutableArray alloc] init];
	
	NSEnumerator *contents = [[[NSFileManager defaultManager] directoryContentsAtPath:__path] objectEnumerator];
	while( contentPath = [contents nextObject] ) {
//		BOOL fDirectory;
//		[[NSFileManager defaultManager] fileExistsAtPath:[__path stringByAppendingPathComponent:contentPath] isDirectory:&fDirectory];
		
		if( [contentPath hasPrefix:@"."] ) {
			// SKIP
		} else {
			[files addObject:[[FileWrapper alloc] initWithPath:[__path stringByAppendingPathComponent:contentPath]]];
		}
	}
	
	return files;
}

+ (NSArray *)filesForPath:(NSString *)__path filter:(NSPredicate *)__filter
{
	NSMutableArray *files = [[NSMutableArray alloc] init];
	NSEnumerator *contents = [[[NSFileManager defaultManager] directoryContentsAtPath:__path] objectEnumerator];
	NSString *contentPath;
	
//	NSLog( @"Path filter is: (%p): %@", __filter, [__filter predicateFormat] );
	
	while( contentPath = [contents nextObject] ) {
		FileWrapper *file = [[FileWrapper alloc] initWithPath:[__path stringByAppendingPathComponent:contentPath]];
		if( __filter == nil || [__filter evaluateWithObject:file] ) {
			[files addObject:file];
		}
	}
	
	return files;
}

- (id)initWithPath:(NSString *)__path
{
	if( ( self = [super init]) != nil )
	{
		path = [[__path stringByExpandingTildeInPath] copy];
	}
	return self;
}

- (NSString *)path
{
	return path;
}

- (NSString *)name
{
	return [[path pathComponents] lastObject];
}

- (void)setName:(NSString*)__name
{
	[self willChangeValueForKey:@"name"];
	
	NSString *newPath = [[[NSFileManager defaultManager] parentPath:[self path]] stringByAppendingPathComponent:__name];
	NSLog( @"Rename %@ to %@", [self path], newPath );
	[[NSFileManager defaultManager] movePath:[self path] toPath:newPath handler:nil];
	
	[self didChangeValueForKey:@"name"];
}

- (BOOL)isFolder
{
	BOOL folder = NO;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self path] isDirectory:&folder];
//	NSLog( @"isFolder(%@) -> %d", [self path], exists && folder );
	return exists && folder;
}

- (BOOL)selected
{
	return selected;
}

- (void)setSelected:(BOOL)__selected
{
	selected = __selected;
}

- (NSImage *)icon
{
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	
	NSImage *sourceIcon = [[NSWorkspace sharedWorkspace] iconForFile:[self path]];
	NSSize sourceSize = [sourceIcon size];
	
	NSImage *resizedIcon = [[NSImage alloc] initWithSize:NSMakeSize( 16, 16 )];
	
	[resizedIcon lockFocus];
	[sourceIcon drawInRect:NSMakeRect( 0, 0, 16, 16 )
				  fromRect:NSMakeRect( 0, 0, sourceSize.width, sourceSize.height )
				 operation:NSCompositeSourceOver
				  fraction:1.0];
	[resizedIcon unlockFocus];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	return resizedIcon;
}

@end
