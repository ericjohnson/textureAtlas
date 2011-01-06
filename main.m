
#import <Foundation/Foundation.h>
#import "TextureAtlasPacker.h"

int main(int argc, char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  //NSArray * images = [NSArray arrayWithObjects:@"roof1.png",@"roof2.png",@"wall1.png",nil];
  NSString * prefix = nil;
  NSMutableArray * images = [NSMutableArray array];
  int size = 512;
  if (argc > 1)
    prefix = [NSString stringWithFormat:@"%s", argv[1]];
  if (argc > 2)
    size = atoi(argv[2]);
  for (int i=3; i<argc; ++i) {
    NSLog(@"image:%s", argv[i]);
    [images addObject:[NSString stringWithFormat:@"%s", argv[i]]];
  }
  
  if (prefix == nil)
    goto bail;
  if ([images count] == 0)
    goto bail;

  NSMutableDictionary * atlasDictionary = [NSMutableDictionary dictionary];
  [TextureAtlasPacker packImages:images intoAtlasesOfSize:NSMakeSize(size,size) atlasDictionary:atlasDictionary prefix:prefix];
  [atlasDictionary writeToFile:[NSString stringWithFormat:@"%@atlas.plist", prefix] atomically:NO];

  goto done;
 bail:
  fprintf(stderr, "usage: textureAtlas [prefix] [size] [image1, image2, ...]\n");
    
 done:
    
  [pool release];
  return 0;
}
