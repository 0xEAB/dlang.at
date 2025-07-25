module dlang_at.app;

import arsd.cgi;

mixin template DlangATMain() {
	import arsd.cgi;
	mixin GenericMain!(serveDlangAT, 1);
}

void serveDlangAT(Cgi cgi) {
	import dlang_at.routes.routing;
	return routeRequest(cgi);
}
