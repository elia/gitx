//
//  PBCommitMessageView.m
//  GitX
//
//  Created by Jeff Mesnil on 13/10/08.
//  Copyright 2008 Jeff Mesnil (http://jmesnil.net/). All rights reserved.
//

#import "PBCommitMessageView.h"

#import "PBGitDefaults.h"
#import "PBGitRepository.h"

@implementation PBCommitMessageView

- (void) awakeFromNib
{
    [super awakeFromNib];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults addObserver:self
               forKeyPath:@"PBCommitMessageViewHasVerticalLine"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    [defaults addObserver:self
               forKeyPath:@"PBCommitMessageViewVerticalLineLength"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    [defaults addObserver:self
               forKeyPath:@"PBCommitMessageViewVerticalBodyLineLength"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

- (void)dealloc
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults removeObserver:self forKeyPath:@"PBCommitMessageViewHasVerticalLine"];
	[defaults removeObserver:self forKeyPath:@"PBCommitMessageViewVerticalLineLength"];
	[defaults removeObserver:self forKeyPath:@"PBCommitMessageViewVerticalBodyLineLength"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)aRect
{
	//self.backgroundColor = [[NSColor whiteColor] colorWithAlphaComponent:1.0];
	//NSRectFill(aRect);
	[super drawRect:aRect];


    if ([PBGitDefaults commitMessageViewHasVerticalLine]) {
		NSGraphicsContext* linesContext = [NSGraphicsContext currentContext];
		[linesContext saveGraphicsState];
		
        CGFloat characterWidth = [@" " sizeWithAttributes:[self typingAttributes]].width;
        CGFloat lineWidth = characterWidth * [PBGitDefaults commitMessageViewVerticalLineLength];
        NSRect line;
        CGFloat padding;
        CGFloat textViewHeight = [self bounds].size.height;

        // draw a vertical line after the given size (used as an indicator
        // for the first line of the commit message)
        padding = [[self textContainer] lineFragmentPadding];
        line.origin.x = padding + lineWidth;
        line.origin.y = 0;
        line.size.width = 5;
        line.size.height = textViewHeight;
		// [[NSColor lightGrayColor] set];
		[[[NSColor systemBlueColor] colorWithAlphaComponent:0.0] setFill];
        NSRectFill(line);

        // and one for the body of the commit message
        lineWidth = characterWidth * [PBGitDefaults commitMessageViewVerticalBodyLineLength];
        padding = [[self textContainer] lineFragmentPadding];
        line.origin.x = padding + lineWidth;
        line.origin.y = 0;
        line.size.width = 1;
        line.size.height = textViewHeight;
		// [[NSColor darkGrayColor] setFill];
		// [[NSColor colorWithCalibratedRed:(0.0) green:(1.0) blue:(0.0) alpha:(0.2)] setFill];
		[[NSColor systemRedColor] setFill];
		NSRectFill(line);
		
		[linesContext restoreGraphicsState];
    }
	
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
		NSString *baseDir = [self.repository.workingDirectory stringByAppendingString:@"/"];
		if (baseDir) {
			NSMutableArray *relativeNames = [NSMutableArray new];
			for (NSString *filename in filenames) {
				if ([filename hasPrefix:baseDir]) {
					NSString *relativeName = [filename substringFromIndex:(baseDir.length)];
					if (relativeName.length) {
						[relativeNames addObject:relativeName];
						continue;
					}
				}
				[relativeNames addObject:filename];
			}
			[pboard clearContents];
			[pboard writeObjects:relativeNames];
		}
    }
	return [super performDragOperation:sender];
}

@end
