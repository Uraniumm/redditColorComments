#import <dlfcn.h>
#import <UIKit/UIKit.h>
#include <objc/message.h>

// Class hierarchy defines, technically this could be in a separate header file
@interface SliceKit : UIView
@end

@interface FlexStackView : SliceKit
@end

// Setup the class pointer for the vertical dividers, init the array of colors
static Class verticalDividerClass;
UIColor *colorPalette[7];

// Clear the color for any dividers passed here (root nodes, award color bars)
void clearRootAwardColor(UIView *verticalDivider) {
    verticalDivider.backgroundColor = [UIColor clearColor];
}

// Set the color scheme for each divider, repeat from beginning every 7 comments (depth)
void logAndSetBackgroundColorByDepth(UIView *verticalDivider, NSInteger depth) {
    UIColor *bgColor = verticalDivider.backgroundColor;
    NSInteger colorIndex = depth % 7;
    UIColor *newColor = colorPalette[colorIndex];

    // Only set the color if it's not already the color it's supposed to be
    if (![bgColor isEqual:newColor]) {
        verticalDivider.backgroundColor = newColor;
    }
}

// Hook class and iterate through all vertical dividers, clear any with a color at root
%hook SliceKit.FlexStackView

// Hook layoutSubviews as it is called every time a divider is setup
- (void)layoutSubviews {
    
    // Run original logic, setup variables for our new custom logic
    %orig();
    NSArray *subviews = [self subviews];
    CGRect frame = [self frame];
    
    // Iterate through every subview (I know, yuck) and store them in an array
    for (NSInteger index = 0; index < subviews.count; index++) {
        id subview = subviews[index];
        
        // Check if the object is actually a vertical divider, bug out if not
        if ([subview isKindOfClass:verticalDividerClass]) {
            
            // Check to see if the divider bar is on the root comment
            if (frame.origin.x == 0) {
                
                // Set the color to clear if so (awarded root comments have a gold band)
                clearRootAwardColor(subview);
            } else {
                
                // Pass the vertical divider object to our function handling color logic
                logAndSetBackgroundColorByDepth(subview, index);
            }
        } else {
            // Bug out (break) if the first subview isn't a vertical divider (it should be)
            break;
        }
    }
}
%end

// This is executed once the tweak loads, think of it like the main function in other languages
%ctor {
    // Resolve the VerticalDivider class by name, there is probably a better way to do this
    verticalDividerClass = objc_getClass("PDP_CommentSheet_Impl.VerticalDivider");
    
    // Colors are setup here, I chose to use the rainbow color scheme Apollo uses
    colorPalette[0] = [UIColor colorWithRed:0.686275 green:0.180392 blue:0.152941 alpha:1.0];
    colorPalette[1] = [UIColor colorWithRed:0.694118 green:0.337255 blue:0.0627451 alpha:1.0];
    colorPalette[2] = [UIColor colorWithRed:0.588235 green:0.466667 blue:0.152941 alpha:1.0];
    colorPalette[3] = [UIColor colorWithRed:0.176471 green:0.439216 blue:0.298039 alpha:1.0];
    colorPalette[4] = [UIColor colorWithRed:0.121569 green:0.407843 blue:0.694118 alpha:1.0];
    colorPalette[5] = [UIColor colorWithRed:0.133333 green:0.27451 blue:0.533333 alpha:1.0];
    colorPalette[6] = [UIColor colorWithRed:0.392157 green:0.231373 blue:0.584314 alpha:1.0];
}
