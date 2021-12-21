import 'package:flutter/material.dart';

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  
  void _sendScreenView(PageRoute<dynamic> route) {
    if(route!=null){
    var screenName = route.settings.name;
    print('previous screenName was $screenName');
    
    }
    else{print('No previous screenName');}
    // do something with it, ie. send it to your analytics service collector
    
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(oldRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}