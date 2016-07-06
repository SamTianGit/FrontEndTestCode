<%@ page import="java.util.*"  %>
<%@ page import="com.nokia.cv.utilityservices.dashboard.*"  %>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="org.springframework.security.core.GrantedAuthority" %>
<%@ page import="org.springframework.security.core.authority.GrantedAuthorityImpl" %>
<%@ page import="org.apache.commons.lang3.StringEscapeUtils"%>
 <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<%


Enumeration<String> en = request.getParameterNames();
System.out.println("-------------------Request parameters  -------------");
while(en.hasMoreElements()) {
	String name = en.nextElement();
	String value = request.getParameter(name);
	System.out.println(name+"="+value);
}

String dashboardName=request.getParameter("dashboard");
String dpDashboard = request.getParameter("dpDashboard");
String cmd = request.getParameter("cmd");

if(dashboardName==null) {
	dashboardName=dpDashboard;
}

if(dashboardName == null) {
	dashboardName = (String)request.getSession().getValue("DASHBOARD_NAME");
} else {
	dashboardName = StringEscapeUtils.escapeJava(dashboardName);
	request.getSession().putValue("DASHBOARD_NAME", dashboardName);
}

/* if("countryActivationName".equals(dashboardName)) {
	Authentication auth = SecurityContextHolder.getContext().getAuthentication();
	System.out.println("Authorities:");
	if(auth != null) {
		Collection<? extends GrantedAuthority> authorities=auth.getAuthorities();
		Iterator<? extends GrantedAuthority>it = authorities.iterator();
	    while(it.hasNext()) {
	    	GrantedAuthority ga = it.next();
	    	System.out.println(ga.getAuthority());
	    }
	} else {
		System.out.println("Authentication is null !!!!!!!!!!!!!!!");
	}
	boolean loggedIn = (request.getSession().getAttribute("LOGGED_IN") == null) ? false : true;
} */

if (dashboardName==null){
        response.sendRedirect("index.jsp?dashboard="+DashboardController.INSTANCE.getFirstDashboard().getName());
}else{
        Dashboard dashboard=DashboardController.INSTANCE.getDashboard(dashboardName);
        Map<String,String[]> userParams=request.getParameterMap();

        Map<String,Object> params=(Map<String,Object>)session.getAttribute("savedParams");
        if (params==null){
                params=new HashMap<String,Object>();
        }
        
        if(cmd != null) {
        	dashboard.processCommand(cmd, userParams);	
        }
        
        InputDefaultsManager defManager=dashboard.getInputDefaultsManager();
        if (defManager!=null){
                Map<String,String> defaultExprs=defManager.getDefaultExpresions();
                for (String defKey:defaultExprs.keySet()){
                 if (params.get(defKey)==null){
                        params.put(defKey,defManager.getDefaultValue(defKey));
                 }
                }
        }
        for (Map.Entry<String,String[]> userParam:userParams.entrySet()){
                params.put(userParam.getKey(), userParam.getValue()[0]);
        }
        String content=dashboard.render(params);
        %><%= content %><%
        Map<String,Object> saveParams=new HashMap<String,Object>(params);
        for (Map.Entry<String,String[]> userParam:userParams.entrySet()){
                if (Dashboard.isVolatileParameter(userParam.getKey())){
                        saveParams.remove(userParam.getKey());
                }
        }
        session.setAttribute("savedParams",saveParams);
}
%>