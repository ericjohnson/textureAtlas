
#import <Foundation/Foundation.h>
#import "TextureAtlasPacker.h"

int main(int argc, char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  //NSArray * images = [NSArray arrayWithObjects:@"roof1.png",@"roof2.png",@"wall1.png",nil];
  NSString * prefix = nil;
  NSMutableArray * images = [NSMutableArray array];
  if (argc > 1)
    prefix = [NSString stringWithFormat:@"%s", argv[1]];
  for (int i=2; i<argc; ++i) {
    NSLog(@"image:%s", argv[i]);
    [images addObject:[NSString stringWithFormat:@"%s", argv[i]]];
  }

  if (prefix == nil)
    goto bail;
  if ([images count] == 0)
    goto bail;

  NSMutableDictionary * atlasDictionary = [NSMutableDictionary dictionary];
  [TextureAtlasPacker packImages:images intoAtlasesOfSize:NSMakeSize(512,512) atlasDictionary:atlasDictionary prefix:@"test"];
  [atlasDictionary writeToFile:@"atlas.plist" atomically:NO];

 bail:
  [pool release];
  return 0;
}
