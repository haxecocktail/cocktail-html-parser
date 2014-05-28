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
package cocktail.parser;

import cocktail.parser.html.InputStream;
import cocktail.parser.html.Tokenizer;
import cocktail.parser.html.TreeBuilder;
import cocktail.parser.html.Token;
import cocktail.parser.html.State;

import js.html.DOMImplementation;
import js.html.Document;
import js.html.DocumentFragment;
import js.html.Element;
import js.html.NodeList;

/**
 * HTML Parser API
 */
class HTMLParser
{
	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#parsing
	 */
	static public function parse(data : String) : Document
	{
		var dom : DOMImplementation;

	#if js
		dom	= js.Browser.document.implementation;
	#end

		// the document that will result of the HTML parsing
		var doc : Document = dom.createHTMLDocument("");
		// clean head
		while(doc.head.childNodes.length > 0) {
			doc.head.removeChild(doc.head.firstChild);
		}

		var is : InputStream = new InputStream(data);

		var tk : Tokenizer = new Tokenizer(is);

		var tb : TreeBuilder = new TreeBuilder(dom, doc);

		tk.onNewToken = function(t : Token) {

				tb.processToken(t);
			}

		tb.onStateChangeRequest = function(s : State) {

				tk.state = s;
			}

		tk.parse();

		// if (doc.readyState == "complete") ?
		return tb.doc;
	}

	/**
	 * @see http://domparsing.spec.whatwg.org/#concept-parse-fragment
	 */
	static public function parseFragment(markup : String, context : Element) : DocumentFragment
	{
		// If the context element's node document is an HTML document: let algorithm be the HTML fragment parsing algorithm.

		// If the context element's node document is an XML document: let algorithm be the XML fragment parsing algorithm.

		// Invoke algorithm with markup as the input, and context element as the context element.
		// Let new children be the nodes returned.
		var newChildren : NodeList = doParseFragment(markup, context);

		// Let fragment be a new DocumentFragment whose node document is context element's node document.
		var fragment : DocumentFragment;

		fragment = context.ownerDocument.createDocumentFragment(); // TODO is this acceptable ?
/*
		TODO check if not necessary #if !js
		fragment.ownerDocument = context.ownerDocument;
*/
		// Append each node in new children to fragment (in order).
		for (n in newChildren) {

			fragment.appendChild(n);
		}
		return fragment;
	}

	/**
	 * @see http://www.w3.org/TR/html5/syntax.html#concept-frag-parse-context
	 * @see https://dvcs.w3.org/hg/innerhtml/raw-file/tip/index.html#dfn-concept-parse-fragment
	 */
	static private function doParseFragment(input : String, context : Element) : NodeList
	{
		var root : Element = null;

		/*
		1 - Create a new Document node, and mark it as being an HTML document.
		*/
		var dom : DOMImplementation;

	#if js
		dom	= js.Browser.document.implementation;
	#end

		// the document that will result of the HTML parsing
		var doc : Document = dom.createHTMLDocument("");
		// clean doc content
		while(doc.documentElement.childNodes.length > 0) {

			doc.documentElement.removeChild(doc.documentElement.firstChild);
		}

		var is : InputStream = new InputStream(input);

		var tk : Tokenizer = new Tokenizer(is);

		var tb : TreeBuilder = new TreeBuilder(dom, doc);

		tk.onNewToken = function(t : Token) {

				tb.processToken(t);
			}

		tb.onStateChangeRequest = function(s : State) {

				tk.state = s;
			}

		/*
		2 - If there is a context element, and the Document of the context element is in quirks mode, 
		then let the Document be in quirks mode. Otherwise, if there is a context element, and the Document 
		of the context element is in limited-quirks mode, then let the Document be in limited-quirks mode. 
		Otherwise, leave the Document in no-quirks mode.
		*/
		// TODO

		/*
		3 - Create a new HTML parser, and associate it with the just created Document node.
		*/


		/*
		4 - If there is a context element, run these substeps:
		*/
		if (context != null) {
			/*
			1 - Set the state of the HTML parser's tokenization stage as follows:

				- If it is a title or textarea element
					Switch the tokenizer to the RCDATA state.
				- If it is a style, xmp, iframe, noembed, or noframes element
					Switch the tokenizer to the RAWTEXT state.
				- If it is a script element
					Switch the tokenizer to the script data state.
				- If it is a noscript element
					If the scripting flag is enabled, switch the tokenizer to the RAWTEXT state. 
					Otherwise, leave the tokenizer in the data state.
				- If it is a plaintext element
					Switch the tokenizer to the PLAINTEXT state.
				- Otherwise
					Leave the tokenizer in the data state.
				
				=> For performance reasons, an implementation that does not report errors and that uses the actual state 
				machine described in this specification directly could use the PLAINTEXT state instead of the RAWTEXT and 
				script data states where those are mentioned in the list above. Except for rules regarding parse errors, 
				they are equivalent, since there is no appropriate end tag token in the fragment case, yet they involve far 
				fewer state transitions.
			*/
			switch (context.tagName) {

				case "title", "textarea":

					tk.state = RCDATA;

				case "style", "xmp", "iframe", "noembed", "noframes":

					tk.state = RAWTEXT;

				case "noscript":

					// TODO
					tk.state = RAWTEXT;

				case "plaintext":

					tk.state = PLAINTEXT;
			}

			/*
			2 - Let root be a new html element with no attributes.
			*/
			//root = doc.createElement("html");
			root = doc.documentElement;

			/*
			3 - Append the element root to the Document node created above.
			*/
			//doc.appendChild(root);

			/*
			4 - Set up the parser's stack of open elements so that it contains just the single element root.
			*/
			tb.stack = [root];

			/*
			5 - If the context element is a template element, push "in template" onto the stack of template insertion 
			modes so that it is the new current template insertion mode.
			*/
			if (context.tagName == "template") {

				// TODO
				throw "not implemented yet!";
			}

			/*
			6 - Reset the parser's insertion mode appropriately.

				=> The parser will reference the context element as part of that algorithm.
			*/
			tb.resetInsertionMode(context);

			/*
			7 - Set the parser's form element pointer to the nearest node to the context element that is a form element 
			(going straight up the ancestor chain, and including the element itself, if it is a form element), if any. 
			(If there is no such form element, the form element pointer keeps its initial value, null.)
			*/
			var e : Element = context;

			while (e.tagName != "form" && e.parentElement != null) {

				e = e.parentElement;
			}
			if (e.tagName == "form") {

				tb.fp = e;
			}
		}
		/*
		5 - Place into the input stream for the HTML parser just created the input. The encoding confidence is irrelevant.
		*/
		// done

		/*
		6 - Start the parser and let it run until it has consumed all the characters just inserted into the input stream.
		*/
		tk.parse();

		/*
		7 - If there is a context element, return the child nodes of root, in tree order.
		*/
		if (context != null) {

			return root.childNodes;
		}

		/*
		8 - Otherwise, return the children of the Document object, in tree order.
		*/
		return doc.childNodes;
	}
}