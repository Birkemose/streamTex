//
//  pgeStreamingTexture.m
//  EIS
//
//  Created by Lars Birkemose on 19/07/11.
//  Copyright 2011 Protec Electronics. All rights reserved.
//
//----------------------------------------------------------------------
// headers

#import "pgeStreamingTexture.h"

//----------------------------------------------------------------------
// implementation

@implementation pgeStreamingTexture

//----------------------------------------------------------------------
// properties

@synthesize texture = m_texture;
@synthesize size = m_size;

//----------------------------------------------------------------------
// methods
//----------------------------------------------------------------------

+( id )streamingTexture {
	return( [ [ [ self alloc ] init ] autorelease ] );
}

//----------------------------------------------------------------------

-( id )init {
	// initialize super
	self = [ super init ];
	
	// initialize self
	m_pixelData = NULL;
	
	// create an OpenGL texture 
	glGenTextures( 1, &m_texture );
	glBindTexture( GL_TEXTURE_2D, m_texture );
	
	// Set filtering parameters appropriate
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
	 
	// create blank image	
	m_pixelData = malloc( STREAMING_TEXTURE_SIZE * STREAMING_TEXTURE_SIZE * STREAMING_TEXTURE_BYTES_PR_PIXEL );
	memset( m_pixelData, 0x7F, STREAMING_TEXTURE_SIZE * STREAMING_TEXTURE_SIZE * STREAMING_TEXTURE_BYTES_PR_PIXEL );
	
	// create texture
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, STREAMING_TEXTURE_SIZE, STREAMING_TEXTURE_SIZE, 0, GL_BGRA, GL_UNSIGNED_BYTE, m_pixelData );

#if TARGET_IPHONE_SIMULATOR
	
	// create image from file

	// NOTE:
	// file MUST be RGBA8, or app crashes
	// This is hardcoded and only intended to enable the class to be compiled on simulator
	CGImageRef image = [ UIImage imageNamed:STREAMING_TEXTURE_FILE ].CGImage;
	CFDataRef data = CGDataProviderCopyData( CGImageGetDataProvider( image ) );
	m_size = CGSizeMake( CGImageGetWidth( image ), CGImageGetHeight( image ) );
	
	// convert RGB to BGRA
	// this is slow and ugly, see note above
	int sourcePos;
	int destinationPos;
	unsigned char* source = ( unsigned char* )CFDataGetBytePtr( data );
	unsigned char* destination = ( unsigned char* )m_pixelData;
	for ( int pixel = 0; pixel < ( m_size.width * m_size.height ); pixel ++ ) {
		sourcePos = pixel * ( STREAMING_TEXTURE_BYTES_PR_PIXEL - 1 );
		destinationPos = pixel * STREAMING_TEXTURE_BYTES_PR_PIXEL;
		destination[ destinationPos + 0 ] = source[ sourcePos + 2 ];
		destination[ destinationPos + 1 ] = source[ sourcePos + 1 ];
		destination[ destinationPos + 2 ] = source[ sourcePos + 0 ];
		destination[ destinationPos + 3 ] = 255;
	}
	
#else
	
	// create capture session
	AVCaptureDeviceInput* captureInput;
	AVCaptureVideoDataOutput* captureOutput;
	dispatch_queue_t queue;
	NSString* key;
	NSNumber* value;
	NSDictionary* videoSettings;
	
	// create video input capture
	captureInput = [ AVCaptureDeviceInput deviceInputWithDevice:[ AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo ] error:nil ];
	
	// create video output capture
	captureOutput = [ [ AVCaptureVideoDataOutput alloc ] init ];
	captureOutput.alwaysDiscardsLateVideoFrames = YES; 
	
	// create frame queue and attach it to video output
	queue = dispatch_queue_create( "pgeStreamingTextureQueue", NULL );
	[ captureOutput setSampleBufferDelegate:self queue:queue ];
	dispatch_release( queue );
	
	// set the format to 32 bit BGRA
	key = ( NSString* )kCVPixelBufferPixelFormatTypeKey; 
	value = [ NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA ]; 
	videoSettings = [ NSDictionary dictionaryWithObject:value forKey:key ]; 
	[ captureOutput setVideoSettings:videoSettings ]; 
	
	// create capture session
	m_captureSession = [ [ AVCaptureSession alloc ] init ];
	m_captureSession.sessionPreset = AVCaptureSessionPresetMedium;
	[ m_captureSession addInput:captureInput ];
	[ m_captureSession addOutput:captureOutput ];
	
	// start the capture
	[ m_captureSession startRunning ];
	
#endif	
		
	// done
	return( self );
}

//----------------------------------------------------------------------

-( void )dealloc {
	// clean up
#if TARGET_IPHONE_SIMULATOR

#else
	
	// release capture session
	[ m_captureSession release ];
	
#endif
	
	// delete textures
	glDeleteTextures( 1, &m_texture );
	free( m_pixelData );
	
	// dealloc super
	[ super dealloc ];
}

//----------------------------------------------------------------------

#if TARGET_IPHONE_SIMULATOR

#else

-( void )captureOutput:( AVCaptureOutput* )captureOutput didOutputSampleBuffer:( CMSampleBufferRef )sampleBuffer fromConnection:( AVCaptureConnection* )connection { 
	NSAutoreleasePool* pool;
	CVPixelBufferRef imageBuffer;
	
	// create autorelease pool
	pool = [ [ NSAutoreleasePool alloc ] init ];
	
	// get pixel buffer and lock it
	imageBuffer = CMSampleBufferGetImageBuffer( sampleBuffer ); 
    CVPixelBufferLockBaseAddress( imageBuffer, 0 ); 
    
	// get image information
    m_size = CGSizeMake( CVPixelBufferGetWidth( imageBuffer ), CVPixelBufferGetHeight( imageBuffer ) );  
		
	// NOTE:
	// Copy texture step could probably be avoided, but since I need the buffer for my own app, it is done this way
	// Isnt that expensive anyways
	
	// copy texture
	memcpy( m_pixelData, CVPixelBufferGetBaseAddress( imageBuffer ), m_size.width * m_size.height * STREAMING_TEXTURE_BYTES_PR_PIXEL );
	
	// unlock image buffer
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	// done
	[ pool drain ];
} 

#endif

//----------------------------------------------------------------------
// renders the texture on a triangle fan

-( void )render:( CGRect )rect {
	CGPoint vertices[ 4 ];
	CGPoint textureCoordinates[ 4 ];
		
	// create vertices
	vertices[ 0 ] = CGPointMake( rect.origin.x, rect.origin.y );
	vertices[ 1 ] = CGPointMake( rect.origin.x + rect.size.width, rect.origin.y );
	vertices[ 2 ] = CGPointMake( rect.origin.x + rect.size.width, rect.origin.y + rect.size.height );
	vertices[ 3 ] = CGPointMake( rect.origin.x, rect.origin.y + rect.size.height );
	
	// create texture coordinates
	textureCoordinates[ 0 ] = CGPointMake( 0, ( float )m_size.height / STREAMING_TEXTURE_SIZE );
	textureCoordinates[ 1 ] = CGPointMake( ( float )m_size.width / STREAMING_TEXTURE_SIZE, ( float )m_size.height / STREAMING_TEXTURE_SIZE );
	textureCoordinates[ 2 ] = CGPointMake( ( float )m_size.width / STREAMING_TEXTURE_SIZE, 0 );
	textureCoordinates[ 3 ] = CGPointMake( 0, 0 );
	
	// set full white
	glColor4ub( 255, 255, 255, 255 );
	glDisableClientState( GL_COLOR_ARRAY );
	
	// bind texture
	glEnable( GL_TEXTURE_2D );
	glBindTexture( GL_TEXTURE_2D, m_texture ); 
	
	// copy streaming data to texture
	glTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, m_size.width, m_size.height, GL_BGRA, GL_UNSIGNED_BYTE, m_pixelData );
	
	// load vertices and texture coordinates	
	glVertexPointer( 2, GL_FLOAT, 0, vertices );
	glTexCoordPointer( 2, GL_FLOAT, 0, textureCoordinates );
	
	// render geometry	
	glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
	
	// reset default states
	glActiveTexture(GL_TEXTURE0);
	glEnableClientState( GL_COLOR_ARRAY );
	glDisable( GL_COLOR_LOGIC_OP );
}

//----------------------------------------------------------------------

@end

