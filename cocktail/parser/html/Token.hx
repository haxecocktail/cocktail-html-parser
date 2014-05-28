/**
 * Cocktail HTML5 parser.
 * @see https://github.com/haxecocktail/cocktail-html-parser
 * 
 * Cocktail, HTML rendering engine
 * http://haxe.org/com/libs/cocktail
 *
 * Copyright (c) Silex Labs 2013 - 2014
 * Cocktail is available under the MIT license
 * http://www.silexlabs.org/labs/cocktail-licensing/
 */
package cocktail.parser.html;

/**
 * DOCTYPE tokens have a name, a public identifier, a system identifier, and a force-quirks flag.
 * When a DOCTYPE token is created, its name, public identifier, and system identifier must be marked
 * as missing (which is a distinct state from the empty string), and the force-quirks flag must be set
 * to off (its other state is on).
 *
 * Start and end tag tokens have a tag name, a self-closing flag, and a list of attributes, each of 
 * which has a name and a value. When a start or end tag token is created, its self-closing flag must 
 * be unset (its other state is that it be set), and its attributes list must be empty. 
 * 
 * Comment and character tokens have data.
 */
enum Token
{
	EOF;
	CHAR( c : Int );
	COMMENT( d : String );
	DOCTYPE( name : String, publicId : String, systemId : String, forceQuirks : Bool );
	START_TAG( tagName : String, selfClosing : Bool, attrs : Map<String,String> );
	END_TAG( tagName : String, selfClosing : Bool, attrs : Map<String,String> );
}