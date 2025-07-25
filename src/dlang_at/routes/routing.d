module dlang_at.routes.routing;

import arsd.cgi;

void routeRequest(Cgi cgi) {
	if (tryShortURL(cgi) == Handled.yes) {
		return;
	}

	sendNotFound(cgi);
}

private:

static immutable contentTypePlaintext = "text/plain; charset=utf-8";
static immutable contentTypeHTML = "text/html; charset=utf-8";

enum Handled : bool {
	no = false,
	yes = true,
}

void writeHtmlEncoded(Cgi cgi, string text) {
	while (text.length > 0) {
		foreach (idx, c; text) {
			string replacement = null;

			switch (c) {
			default:
				break;
			case '&':
				replacement = "&amp;";
				break;
			case '<':
				replacement = "&lt;";
				break;
			case '>':
				replacement = "&gt;";
				break;
			}

			if (replacement !is null) {
				if (idx > 0) {
					cgi.write(text[0 .. idx]);
				}

				cgi.write(replacement);
				text = text[(idx + 1) .. $];
				break;
			}

			char[1] buffer = [c];
			cgi.write(buffer[]);
		}

		break;
	}
}

void sendRedirect(Cgi cgi, string location, int responseCode = 302) {
	cgi.setResponseStatus(responseCode);
	cgi.setResponseLocation(location);
	cgi.setResponseContentType(contentTypeHTML);

	cgi.write(`<!DOCTYPE html><html><body><a href="`);
	cgi.write(location);
	cgi.write(`">`);
	cgi.writeHtmlEncoded(location);
	cgi.write("</a></body></html>\n");
}

Handled checkRequestMethod(Cgi cgi) {
	static immutable response405 = `"Unsupported request method. How about HEAD/GET/OPTIONS?"`;

	switch (cgi.requestMethod) {
	case Cgi.RequestMethod.HEAD:
	case Cgi.RequestMethod.GET:
		return Handled.no;

	case Cgi.RequestMethod.OPTIONS:
		cgi.header("Allow: GET, HEAD, OPTIONS");
		cgi.setResponseContentType(contentTypePlaintext);
		return Handled.yes;

	default:
		cgi.setResponseStatus(405);
		cgi.setResponseContentType(contentTypePlaintext);
		cgi.write(response405);
		return Handled.yes;
	}
}

Handled tryShortURL(Cgi cgi) {
	import dlang_at.routes.shorturl;

	const shortURL = resolveShortURL(cgi.pathInfo);
	if (!shortURL.found) {
		return Handled.no;
	}

	if (checkRequestMethod(cgi) == Handled.yes) {
		return Handled.yes;
	}

	cgi.sendRedirect(shortURL.target);
	return Handled.yes;

}

void sendNotFound(Cgi cgi) {
	cgi.setResponseStatus(404);
	cgi.setResponseContentType(contentTypePlaintext);
	cgi.write("The requested page could not be found: ");
	cgi.write(cgi.pathInfo);
}
