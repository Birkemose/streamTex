//
//  HelloWorldLayer.h
//  StreamTex
//
//  Created by Lars Birkemose on 15/08/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "pgeStreamingTexture.h"


#define SITTING_POS_X			120
#define SITTING_POS_Y			100
#define SITTING_SCALE			0.6f


// HelloWorld Layer
@interface HelloWorld : CCColorLayer
{
	pgeStreamingTexture*	m_stream;
	CCSprite*				m_sittingMan;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
