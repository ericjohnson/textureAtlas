
#import <Foundation/Foundation.h>

@interface TextureAtlasPacker : NSObject
{
}
+ (BOOL) packImages:(NSArray *)images intoAtlasesOfSize:(NSSize)size atlasDictionary:(NSMutableDictionary *)atlasDictionary prefix:(NSString *)prefix;
+ (BOOL) packImages:(NSArray *)imageFiles intoTextureAtlas:(NSString *)textureAtlas ofSize:(NSSize)size atlasDictionary:(NSMutableDictionary *)atlasDictionary;

@end
