package unit;

import utest.Assert;
import utest.Runner;
import utest.ui.Report;

import js.html.Document;
import js.html.DocumentFragment;
import js.html.Node;
import js.html.Element;

import cocktail.parser.HTMLParser;
import cocktail.parser.HTMLSerializer;

/**
 * ...
 * @author Thomas Fétiveau
 */
class Test
{
	public static function main()
	{
        var runner = new Runner();
        runner.addCase(new Test());
        Report.create(runner);
        runner.run();
    }
	
	public function new() { }

	public function testParseHtmlFragment()
	{

		trace("*** TESTING HTML FRAGMENT PARSING ***");
		var docStr : String = "<html><head><title></title></head><body><h1>heading</h1><p id='ih'></p><p id='re' class='toto'>paragraph</p><body></html>";
		var doc : Document = HTMLParser.parse(docStr);
		trace(HTMLSerializer.serialize(doc));
		Assert.notNull( doc );
		//dumpNode(doc);

		var ip : Element = doc.getElementById("ih");

		var fragment : DocumentFragment = HTMLParser.parseFragment("<u>Dominos is</u> <i>SO</i> <b>COOL</b>!", ip);

		ip.appendChild(fragment);

		//dumpNode(doc);
		trace(HTMLSerializer.serialize(doc));

		trace("ip outerHTML is:");
		trace(ip.outerHTML);
		var fragment2 : DocumentFragment = HTMLParser.parseFragment("<div><p>Very</p> <span>Cool!</span></div>", ip);
		ip.parentNode.replaceChild(fragment2, ip);
		//dumpNode(doc);
		trace(HTMLSerializer.serialize(doc));
	}

	public function testParseSimpleHtml()
	{
		trace("*** TESTING SIMPLE HTML PARSING ***");
		var docStr : String = "<!DOCTYPE html>
<html>
	<head>
		<title>Cocktail Sample</title>
	</head>
	<body>
		<h1>Hello World !</h1>
		<div>
			<p>
				Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras dignissim lorem a purus semper scelerisque. 
				Mauris eu quam lacus, a pellentesque neque. Suspendisse nec tristique turpis. Mauris et eros non nisi congue 
				condimentum. Aliquam erat volutpat. Integer eget dignissim libero. Aliquam tellus odio, mollis vel pellentesque 
				at, dapibus pulvinar mi. Ut convallis, quam nec tincidunt porttitor, velit odio pharetra lectus, sit amet sodales 
				lacus risus in urna. Aliquam imperdiet, massa ut placerat viverra, justo odio tempor purus, a ultricies neque lectus 
				vel ipsum.
			</p>
		</div>
	</body>
</html>";
		var doc : Document = HTMLParser.parse(docStr);
		trace(HTMLSerializer.serialize(doc));
		Assert.notNull( doc );
		//dumpNode(doc);
	}

	public function testParseRemotePage()
	{
		trace("*** TESTING REMOTE HTML PAGE PARSING ***");
		var url : String = "http://www.w3.org/TR/html5/Overview.html#contents";
		var docStr: String = haxe.Http.requestUrl( url );
		
		var doc : Document = HTMLParser.parse(docStr);
		trace(HTMLSerializer.serialize(doc));
		Assert.notNull( doc );
		//dumpNode(doc);
	}

	static public function dumpNode( n : Node, ?i : Int = 0 ) : Void
	{
		var indent : StringBuf = new StringBuf(); for ( y in 0...i) { indent.addChar( 0x20 ); }
		trace(  indent.toString() + n.nodeName );
		for (nc in n.childNodes)
		{
			dumpNode( nc, i + 1 );
		}
	}

}