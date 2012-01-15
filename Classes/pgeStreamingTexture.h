//
//  pgeStreamingTexture.h
//  EIS
//
//  Created by Lars Birkemose on 19/07/11.
//  Copyright 2011 Protec Electronics. All rights reserved.
//
//----------------------------------------------------------------------
//  
//  Defines an OpenGL texture
//
//----------------------------------------------------------------------
// headers

#import "GameConfig.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <AVFoundation/AVFoundation.h>
#import "TargetConditionals.h"

//----------------------------------------------------------------------
// defines

#define STREAMING_TEXTURE_FILE					@"test.png"				
#define STREAMING_TEXTURE_SIZE					512
#define STREAMING_TEXTURE_BYTES_PR_PIXEL		4

#define STREAMING_TEXTURE_V0					CGPointMake( 320, 175 )

#define STREAMING_TEXTURE_V1					CGPointMake( 220, 250 )
#define STREAMING_TEXTURE_V2					CGPointMake( 420, 300 )
#define STREAMING_TEXTURE_V3					CGPointMake( 420, 050 )
#define STREAMING_TEXTURE_V4					CGPointMake( 220, 100 )

//----------------------------------------------------------------------
// typedefs

//----------------------------------------------------------------------
// interface

#if TARGET_IPHONE_SIMULATOR

@interface pgeStreamingTexture : NSObject {
	GLuint				m_texture;
	CGSize				m_size;
	unsigned char*		m_pixelData;
}

#else
	
@interface pgeStreamingTexture : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession*	m_captureSession;
	GLuint				m_texture;
	CGSize				m_size;
	unsigned char*		m_pixelData;
}

#endif


//----------------------------------------------------------------------
// properties

@property ( readonly )GLuint texture;
@property ( readonly )CGSize size;

//----------------------------------------------------------------------
// methods

+( id )streamingTexture;
-( id )init;

-( void )render:( CGRect )rect;

//----------------------------------------------------------------------

@end
