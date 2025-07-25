/++
	Short URL service
 +/
module dlang_at.routes.shorturl;

import std.string;

@safe:

struct ShortURLResult {
	bool found = false;
	string target;
}

ShortURLResult resolveShortURL(string path) {
	if (path.length < 1) {
		return ShortURLResult(false);
	}
	path = path.strip("/");

	static foreach (ShortURL shortURL; shortURLs) {
		if (path == shortURL.slug) {
			return ShortURLResult(true, shortURL.target);
		}
	}

	return ShortURLResult(false);
}

private:

enum shortURLsRaw = import("short_urls.ini");
enum shortURLs = () {
	import dlang_at.ini;

	const doc = parseINI(shortURLsRaw);
	const targets = doc["targets"];
	const slugs = doc["slugs"];

	ShortURL[] result;

	foreach (slug, targetName; slugs) {
		result ~= ShortURL(slug, targets[targetName]);
	}

	return result;
}();

struct ShortURL {
	string slug;
	string target;
}
