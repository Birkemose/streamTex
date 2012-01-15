//
//  HelloWorldLayer.m
//  StreamTex
//
//  Created by Lars Birkemose on 15/08/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// Import the interfaces
#import "HelloWorldScene.h"

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	
	// if( (self=[super initWithColor:( ccColor4B ){ 255, 255, 255, 255 } ] )) {
	if( (self=[super init] )) {
		
		
		// create streaming texture
		// add video stream
		m_stream = [ [ pgeStreamingTexture streamingTexture ] retain ];
		
		// CCSprite* screen = [ CCSprite spriteWithTexture:<#(CCTexture2D *)texture#> ]
		
		// create siting man
		m_sittingMan = [ CCSprite spriteWithFile:@"sitting.png" ];
		m_sittingMan.position = CGPointMake( SITTING_POS_X, SITTING_POS_Y );
		m_sittingMan.scale = SITTING_SCALE;
		[ self addChild:m_sittingMan ];
		
	}
	return self;
}

-( void )visit {

	// NOTE:
	// This is some really ugly hardcoded stuff.
	// Never ever do it like this :)
	
	// Only made to make the screen look slightly more interresting
	
	glPushMatrix();
	//rotate screen into position
	glRotatef( -35.0f, 0.0f, 1.0f, 0.0f );
	glRotatef( 10.0f, 1.0f, 0.0f, 0.0f );
	[ m_stream render:CGRectMake( 280, 130, 80, 60 ) ];
	glPopMatrix();	

	[ m_sittingMan visit ];
	
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
