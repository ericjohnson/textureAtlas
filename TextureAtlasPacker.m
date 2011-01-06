
#import "TextureAtlasPacker.h"
#import <AppKit/AppKit.h>

@implementation TextureAtlasPacker

+ (BOOL) packImages:(NSArray *)images intoAtlasesOfSize:(NSSize)size atlasDictionary:(NSMutableDictionary *)atlasDictionary prefix:(NSString *)prefix;
{
  if ([atlasDictionary objectForKey:@"images"] == nil) {
    [atlasDictionary setObject:[NSMutableDictionary dictionary] forKey:@"images"];
  }

  NSMutableArray * toFit = [NSMutableArray arrayWithArray:images];
  
  int index = 0;
  
  while ([toFit count] > 0) {
    NSMutableArray * couldNotFit = [NSMutableArray array];
    NSString * nextAtlasName = [NSString stringWithFormat:@"%@atlas%d.png", prefix, index];
    while ([toFit count] > 0 &&
	   [self packImages:toFit intoTextureAtlas:nextAtlasName ofSize:size atlasDictionary:atlasDictionary] == NO) {
      if ([toFit count] > 1) //make sure we don't get stuck in an infinite loop
	[couldNotFit addObject:[toFit lastObject]];
      [toFit removeLastObject];
    }
    NSLog(@"grouped into atlas together: %@", [toFit description]);
    if ([toFit count] > 0) {
      index++;
    }
    toFit = couldNotFit;
  }
  
  
  return YES;
}

+ (BOOL) packImages:(NSArray *)imageFiles intoTextureAtlas:(NSString *)textureAtlas ofSize:(NSSize)size atlasDictionary:(NSMutableDictionary *)atlasDictionary;
{
  int totalArea = 0;
  for (NSString * imageFile in imageFiles) {
    NSImage * image = [[[NSImage alloc] initWithContentsOfFile:imageFile] autorelease];
    totalArea += (int)(image.size.width*image.size.height);
  }
  NSLog(@"totalArea: %d", totalArea);
  fprintf(stderr, "\n\n\n");
  
  if (totalArea > size.width*size.height) {
    NSLog(@"bailing early, impossible to fit in requested size");
    return NO;
  }

  NSMutableArray * blocks = [NSMutableArray arrayWithArray:imageFiles];
  NSMutableArray * placedBlocks = [NSMutableArray array];

  NSMutableDictionary * placements = [NSMutableDictionary dictionary];

  NSRect enclosingRectangle = NSZeroRect;
  
  //place the first image
  NSString * firstFile = [blocks lastObject];
  NSImage * first = [[[NSImage alloc] initWithContentsOfFile:firstFile] autorelease];

  [blocks removeLastObject];
  [placedBlocks addObject:firstFile];

  NSRect firstPlacement = NSMakeRect(0, 0, first.size.width, first.size.height);
  [placements setObject:[NSValue valueWithRect:firstPlacement] forKey:firstFile];

  enclosingRectangle = firstPlacement;

  for (NSString * block in blocks) {
    int objective = INT_MAX; //find the best placement for block, need to reset objective so that we can minimize
    NSRect bestPlacement = NSZeroRect;
    NSImage * image = [[[NSImage alloc] initWithContentsOfFile:block] autorelease];
    for (NSString * placed in placedBlocks) {
      NSRect placedRect = [[placements objectForKey:placed] rectValue];
      for (int a = 0; a < 4; ++a) {
 	for (int b = 0; b < 4; ++b) {
 	  //place corner b of block on corner a of placed
 	  //corner 0: bottom left
 	  //corner 1: bottom right
 	  //corner 2: top left
 	  //corner 3: top right
	  NSRect placement = NSZeroRect;
 	  placement.size = image.size;
 	  //where do we put it?
	  NSPoint origin = NSZeroPoint;
 	  switch (a) {
 	  case 0:
 	    origin = placedRect.origin;
 	    break;
 	  case 1:
 	    origin = NSMakePoint(placedRect.origin.x+placedRect.size.width, placedRect.origin.y);
 	    break;
 	  case 2:
 	    origin = NSMakePoint(placedRect.origin.x, placedRect.origin.y+placedRect.size.height);
 	    break;
 	  case 3:
 	    origin = NSMakePoint(placedRect.origin.x+placedRect.size.width, placedRect.origin.y+placedRect.size.height);
 	    break;
 	  }
 	  switch (b) {
 	  case 0:
 	    //nothing, already in right place
 	    break;
 	  case 1:
 	    origin = NSMakePoint(origin.x-image.size.width, origin.y);
 	    break;
 	  case 2:
 	    origin = NSMakePoint(origin.x, origin.y-image.size.height);
 	    break;
 	  case 3:
 	    origin = NSMakePoint(origin.x-image.size.width, origin.y-image.size.height);
 	    break;
 	  }
 	  //check boundary conditions
 	  if (origin.x < 0 || origin.y < 0 ||
 	      origin.x+image.size.width > size.width ||
 	      origin.y+image.size.height > size.height)
 	    break;
 	  //check overlap conditions
 	  NSRect potentialPlacement = NSMakeRect(origin.x, origin.y, image.size.width, image.size.height);
 	  BOOL overlaps = NO;
 	  for (NSString * placed2 in placedBlocks) {
 	    NSRect placedRect2 = [[placements objectForKey:placed2] rectValue];
 	    if (NSIntersectsRect(potentialPlacement, placedRect2)) {
 	      overlaps = YES;
 	      break;
 	    }
 	  }
 	  if (overlaps)
 	    break;
 	  //calculate newObjective
 	  NSRect potentialEnclosingRectangle = enclosingRectangle;
 	  if (potentialEnclosingRectangle.size.width < potentialPlacement.origin.x+potentialPlacement.size.width)
 	    potentialEnclosingRectangle.size.width = potentialPlacement.origin.x + potentialPlacement.size.width;
 	  if (potentialEnclosingRectangle.size.height < potentialPlacement.origin.y+potentialPlacement.size.height)
 	    potentialEnclosingRectangle.size.height = potentialPlacement.origin.y + potentialPlacement.size.height;
 	  int newObjective = potentialEnclosingRectangle.size.width*potentialEnclosingRectangle.size.height +
 	    (potentialPlacement.origin.y + potentialEnclosingRectangle.size.width)/2;
 	  if (newObjective < objective) {
 	    objective = newObjective;
 	    bestPlacement = potentialPlacement;
 	  }
 	}
       }
    }
     //check if we found a placement
    if (NSEqualRects(bestPlacement, NSZeroRect)) {
      NSLog(@"Could not find a valid placement! bailing...");
      return NO;
    }
    
    //add best placement to placements
    [placements setObject:[NSValue valueWithRect:bestPlacement] forKey:block];
    [placedBlocks addObject:block];
    
    if (enclosingRectangle.size.width < bestPlacement.origin.x+bestPlacement.size.width)
      enclosingRectangle.size.width = bestPlacement.origin.x + bestPlacement.size.width;
    if (enclosingRectangle.size.height < bestPlacement.origin.y+bestPlacement.size.height)
      enclosingRectangle.size.height = bestPlacement.origin.y+bestPlacement.size.height;
  }
  
  unsigned char * data = malloc(size.width*size.height*4*sizeof(unsigned char));
  CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
  CGContextRef imageContext = CGBitmapContextCreate(data,
						    size.width,
						    size.height,
						    8,
						    size.width*4,
						    colorspace,
						    kCGImageAlphaPremultipliedLast);
  
  CGColorSpaceRelease(colorspace);
  
  //can i somehow erase everything in imageContext?
  CGContextClearRect(imageContext,
		     CGRectMake(0, 0, size.width, size.height));
  
  //update atlasDictionary
  NSMutableDictionary * imagesDict = [atlasDictionary objectForKey:@"images"];
//   CGContextScaleCTM(imageContext, 1.0, -1.0);
//   CGContextTranslateCTM(imageContext, 0.0, -size.height);

  for (NSString * imageFile in placements) {
    NSMutableDictionary * imageInfo = [NSMutableDictionary dictionary];
    NSImage * image = [[[NSImage alloc] initWithContentsOfFile:imageFile] autorelease];
    CGImageRef cgimage = [image CGImageForProposedRect:NULL context:nil hints:nil];
    NSRect placement = [[placements objectForKey:imageFile] rectValue];
    NSRect realPlacement = NSMakeRect(placement.origin.x, size.height-placement.origin.y-placement.size.height,
				      placement.size.width, placement.size.height);
    CGContextDrawImage(imageContext,
 		       realPlacement,
 		       cgimage);
    [imageInfo setObject:textureAtlas forKey:@"atlas"];
    [imageInfo setObject:[NSNumber numberWithFloat:placement.origin.x] forKey:@"placement.origin.x"];
    [imageInfo setObject:[NSNumber numberWithFloat:placement.origin.y] forKey:@"placement.origin.y"];
    [imageInfo setObject:[NSNumber numberWithFloat:placement.size.width] forKey:@"placement.size.width"];
    [imageInfo setObject:[NSNumber numberWithFloat:placement.size.height] forKey:@"placement.size.height"];
    [imagesDict setObject:imageInfo forKey:imageFile];
  }
  
  CGImageRef atlasCGImage = CGBitmapContextCreateImage(imageContext);
  NSBitmapImageRep * atlasImage = [[[NSBitmapImageRep alloc] initWithCGImage:atlasCGImage] autorelease];
  NSData * imageData = [atlasImage representationUsingType:NSPNGFileType
				   properties:nil];
  [imageData writeToFile:textureAtlas atomically:NO];
  
  CGImageRelease(atlasCGImage);
  
  CGContextRelease(imageContext);
  free(data);
  
  return YES;
  
}

@end

