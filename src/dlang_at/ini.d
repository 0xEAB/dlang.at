module dlang_at.ini;

import arsd.ini;

// dfmt off
private enum dialect = (
	  IniDialect.colonKeys

	| IniDialect.lineComments
	| IniDialect.inlineComments
	| IniDialect.hashLineComments
	| IniDialect.hashInlineComments

	| IniDialect.quotedStrings
	| IniDialect.singleQuoteQuotedStrings
);
// dfmt on

///
auto parseINI(string)(string rawIni) => parseIniAA!dialect(rawIni);
