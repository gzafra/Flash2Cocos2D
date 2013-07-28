<h2>Version notes:</h2>

<b>Fork of Flash2Cocos2D modified to:</b>
- Use spriteSheets and batchNodes (a blank.png sprite is added in every FTCCharacter, so that texture must exist on the sprite sheet). Also note that for different sprites, a suffix should be added to avoid using the same name.
- Preload all parts and animations for every XML, so that its only loaded once and not in runtime. (This allows a more heavy use of the library without destroying performance).
- Update ContentSize of each FTCCharacter aproximately using part positions and animations.
- Also load color and alpha from xml.
- Stop scheduler after an animation finishes if loop is set to false.

<h3>Additional notes:</h3>
- This code has been stripped from the project so it may need some tweaking before using it on another project.
-  [self scheduleAnimation] is commented on line 286 of FTCCharacter.m. Uncomment or call manually.
-  If an animation finished and is not set to loop, it will unschedule the internal update to improve performance. If another animation is later triggered,  [self scheduleAnimation] will need to be called manually again.
- ARC is no longer used in the library, keep that in mind.
- Working with Cocos2d 2.0
- ColorUtils utility class added to parse colors in hex from XML into ccColor3B
- __FTCOPTIMIZED global constant must be added and set to true if you want preloading to work. This flag was used to test performance between the two systems.
- kDebugFTC global constant must be added and set to true or false wheter you want debug graphics to be shown.
- I apologize in advance for any english mistake or if you find some spanish comments.

<b> Hope I don't forget anything. If you have any problem getting it to work, don't hesitate to contact me.</b>

FlashToCocos2D
===============


This tool provides a fast way of reusing animations made in Flash CS in Cocos2D projects.
A minimaly tweaked version of the amazing exporter by [Grapefrukt](https://github.com/grapefrukt/grapefrukt-export) provides a way to export all the animation information (position, rotation, scale) of a Flash made character to xml.
The FlashToCocos iOS library reads those xml files and recreates the characters in Cocos2D.

<h2>Basic workflow:</h2>

<h3>FLASH SIDE:</h3>
- create your character in Flash 
- create as many animations a needed
- every animation has to have a keyframe labeled with an unique name. IE: "*dancing*", "*running*"...
- to launch custom events during an animation, you can use keyframes labels prefixed with @. IE: "*@launchSound*"
- select 'Export for Actionscript' for your character MovieClip
- add the Grapefukrt exporting code on the first frame:

	```actionscript
	import com.grapefrukt.exporter.simple.SimpleExport;
	import com.grapefrukt.exporter.extractors.*;
	// change robot for whatever name you want to use
	var export:SimpleExport = new SimpleExport(this, "robot"); 
	// change RobotCharacterMc for whatever name you MovieClip is in the library
	export.textures.add(TextureExtractor.extract(new RobotCharacterMc)); 
	AnimationExtractor.extract(export.animations, new RobotCharacterMc);
	export.export();
	```

- publish
- on the top left corner click on "*click to output*"
- save the zip file
- unzip the zip file


<h3>XCODE:</h3>

- start a Cocos2D project
- enabled ARC following this [instructions](http://www.tinytimgames.com/2011/07/22/cocos2d-and-arc/)
- add the FlashToCocos Library
- add the [TBXML Library](http://tbxml.co.uk/)
- add the results of unzipping the file created from Flash


<h2>FTCCharacter Class</h2>
<h3>Overview</h3>
FTCharacter is the main class to be used. It extends CCLayer and it's the responsible to load the XML files and textures.
There are still a lot of methods exposed that shouldn't be. Hopefully we'll be able to clear the code a little bit in short time.
<h3>Class Methods</h3>

```-(FTCharacter) characterFromXMLFile:(NSString *)xmlFileName```

Reads and XML, loads texture and returns a FTCCharacter.<br/>
IE: <code>FTCharacter *robot = [FTCharacter characterFromXMLFile:@"robot"]</code>

<h3>Instance Methods</h3>

<code>-(void) playAnimation:(NSString *)animation loop:(BOOL)loops wait:(BOOL)waits</code>

Starts playing the specified **animation**. It will **loop** it if specified.
The wait parameter indicates if this animation should **wait** for the previous one to finish before start playing.

<code>-(void) stopAnimation</code>

Stops the current animation being played.

<code>-(void) pauseAnimation</code>

Pauses the current animation.

<code>-(void) resumeAnimation</code>

Resumes the current paused animation.

<code>-(void) playFrame:(int)_frameIndex fromAnimation:(NSString *)_animationId</code>

Sets the character to the specified **frame** for the specified **animation**.
